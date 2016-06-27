# Wyvernscale Source Code Editor (wsedit)

# IMPORTANT NOTICE regarding the `0.3.*` update

* The parameter syntax for highlighting has changed slightly, therefore your old
  config files may be invalid.  To avoid breakage, we now use new file locations:

  * `~/.config/wsedit.wsconf` instead of `~/.config/wsedit.conf`
  * `./.local.wsconf` instead of `./.wsedit`

  Check out the new syntax for `-f*` parameters with `wsedit -h`.

* Entire language definitions are now available in the `lang/` subdirectory.
  Install them as follows:

  * `cd` into the main git directory, `git pull origin master` to ensure you
    have the latest version.
  * Run `lang/install.sh` to list all available languages.
  * Use `lang/install.sh <language name>` to append a definition to your
    global config.
  * Pull requests for your favourite language are always welcome!

## Introduction

`wsedit` is a neat **little** (as in *don't expect too much from a student's
first piece of code on github*) terminal-based editor written in haskell,
sitting comfortably in the niche between `nano` and `vim`.  It is designed to be
intuitive (as in "Press Ctrl-C to copy stuff"), work out-of-the-box with every
conceivable language and to require only a minimal amount of configuration.

## Features

* __Read-only mode__: Want to glance over a file without accidentally editing
  it?  Start the editor in read-only mode (by passing `-r`), and toggle it in
  the editor with `Ctrl-Meta-R`.

* __Dynamic dictionary-based autocompletion__: When activated, everytime you
  load or save, `wsedit` will read all files with the same ending as the one
  you're currently editing, filter all lines by indentation depth and build a
  dictionary out of those at a specified level.

* __Pragmatic syntax highlighting__: Highlights keywords, strings and comments
  according to your configuration file.  Default patterns are availabe in
  `lang/*.wsconf`.

* __Character class highlighting__: Not as powerful as full-on syntax
  highlighting, it will instead color your text by character class (e.g.
  operators -> yellow, brackets -> brown, numbers -> red, ...).  This, in
  combination with the syntax highlighting, offers a comfortable editing
  experience while being easy to tweak yourself.

* __The usual selection editing, interacting directly with the system
  clipboard__: Make sure to have `xclip` or `xsel` installed; an internal
  fallback is provided.

* __Easiest possible method of configuration__: Type `wsedit -cg` (global) or
  `wsedit -cl` (directory-local) to open the configuration file, then put down
  all the command line parameters you'd like to be default.  Prefix lines with
  e.g. `hs:` to make them apply to .hs-files only.

## Building

1. Install the
   [Haskell Tool Stack](http://docs.haskellstack.org/en/stable/README/).
2. *Optional*: Install either `xclip` or `xsel` with your package manager.  If
   this step is skipped, `wsedit` will use an internal buffer instead of the
   system facilities for copy/paste functionality.
3. Clone the repository (`git clone https://github.com/SirBoonami/wsedit`).
4. `cd` into the newly created directory (`cd wsedit`).
5. Run `stack setup` to pull in the correct version of `ghc`.
6. Run `stack install` to build the dependencies and `wsedit`.
7. Either:
    * Add `~/.local/bin/` to your `$PATH`
    * Copy `~/.local/bin/wsedit` to a directory in your `$PATH`, e.g.
      `/usr/local/bin/`.
8. To install language definitions, create the folder `~/.config/wsedit` and
   paste them there.  Quite a few languages and formats have pre-defined
   highlighting rules in the `lang` subdirectory of this repository, feel free
   to write your own and create a pull request!
9. Run `wsedit <some file>` to test everything, or `wsed -h` for a list of all
   the available options.

**Sometimes the build may fail due to obscure reasons, deleting the local
`.stack-work` build folder fixed it everytime for me.**

## Known issues

* `wsedit` may be a bit on the slow side on older systems. Use `-b` to disable
  background rendering, which remedies this for the most part.
