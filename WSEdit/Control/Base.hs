module WSEdit.Control.Base
    ( refuseOnReadOnly
    , alterBuffer
    , alterState
    , moveViewport
    , moveCursor
    , fetchCursor
    ) where


import Control.Monad            (unless)
import Control.Monad.RWS.Strict (get, modify, put)

import WSEdit.Data              ( EdState  ( canComplete, cursorPos, edLines
                                           , readOnly, scrollOffset, wantsPos
                                           )
                                , WSEdit
                                , alter, getCursor, getOffset, setCursor
                                , setStatus, setOffset
                                )
import WSEdit.Output            ( cursorOffScreen, getViewportDimensions
                                , txtToVisPos, visToTxtPos
                                )
import WSEdit.Util              (withPair)

import qualified WSEdit.Buffer as B





-- | Guard the given action against use in read-only mode. Will use 'setStatus'
--   to issue a warning.
refuseOnReadOnly :: WSEdit () -> WSEdit ()
refuseOnReadOnly a = do
    s <- get
    if readOnly s
       then setStatus "Warning: read only (press Ctrl-Meta-R to enable editing)"
       else a


-- | Declares that an action will alter the text buffer. Calls
--   'refuseOnReadOnly', creates an undo point, wiggles the cursor to ensure it
--   is in a valid position, ...
alterBuffer :: WSEdit () -> WSEdit ()
alterBuffer a = refuseOnReadOnly
              $ alterState
              $ modify (\s -> s { wantsPos = Nothing })
             >> moveCursor 0 0
             >> alter
             >> a


-- | Declares that an action will alter the text buffer or the cursor position.
--   Included in 'alterBuffer'.
alterState :: WSEdit () -> WSEdit ()
alterState a = modify (\s -> s { canComplete = False })
            >> a



-- | Moves the viewport by the given amount of rows, columns.
moveViewport :: Int -> Int -> WSEdit ()
moveViewport r c = do
    getOffset
        >>= setOffset
            . withPair
                (max 0 . (+r))
                (max 0 . (+c))





-- | Moves the cursor by the given amount of rows, columns, dragging the
--   viewport along when neccessary. The cursor's movements will be limited
--   by the shape of the underlying text, but pure vertical movement will try to
--   maintain the original horizontal cursor position until horizontal movement
--   occurs or 'alterBuffer' is called.
moveCursor :: Int -> Int -> WSEdit ()
moveCursor r c = alterState $ do
    b <- readOnly <$> get
    if b
       then moveViewport r c
       else do
            moveV r
            unless (c == 0) $ moveH c

            -- Adjust the viewport if necessary
            ((ru, rd), (cl, cr)) <- cursorOffScreen
            moveViewport (rd - ru) (cr - cl)

    where
        -- | Vertical portion of the movement
        moveV :: Int -> WSEdit ()
        moveV n = do
            (currR, currC) <- getCursor
            s <- get

            let lns      = edLines s
                currLn   = B.curr lns
                tLnNo    = min (B.length lns) $ max 1 $ currR + n
                targetLn = B.atDef "" lns $ tLnNo - 1

            -- Current visual cursor offset (amount of columns)
            vPos <- txtToVisPos currLn currC

            -- Targeted visual cursor offset
            tPos <- case wantsPos s of
                 Nothing -> do
                    unless (n == 0)
                        $ modify (\s' -> s' { wantsPos = Just vPos })
                    return vPos

                 Just p  -> do
                    return p

            -- Resulting textual cursor offset (amount of characters)
            newC <- visToTxtPos targetLn tPos
            setCursor (tLnNo, newC)

        -- | Horizontal portion of the movement
        moveH :: Int -> WSEdit ()
        moveH n = do
            (currR, currC) <- getCursor
            lns <- edLines <$> get

            let currLn = B.curr lns

            setCursor (currR
                      , min (length currLn + 1)
                      $ max 1
                      $ currC + n
                      )

            -- Since this function will not be called for purely vertical
            -- motions, we can safely discard the target cursor position here.
            modify (\s -> s { wantsPos = Nothing })



-- | Moves the cursor to the upper left corner of the viewport.
fetchCursor :: WSEdit ()
fetchCursor = refuseOnReadOnly $ do
    s <- get
    (r, _) <- getViewportDimensions

    put $ s { cursorPos = 1
            , edLines = B.toFirst $ edLines s
            }

    moveCursor (fst (scrollOffset s) + (r `div` 2)) 0
