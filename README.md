# My dotfiles

My dotfiles for Arch Linux.

Overall info:

* Terminal: [alacritty](https://github.com/alacritty/alacritty)
* Shell: [zsh](https://wiki.archlinux.org/index.php/zsh)
* Editor: [neovim](https://neovim.io/)
* File manager: [nnn](https://github.com/jarun/nnn), [thunar](https://wiki.archlinux.org/index.php/Thunar)
* Fonts: [SF Mono](https://github.com/supercomputra/SF-Mono-Font), [Product Sans](https://befonts.com/product-sans-font.html)
* Status bar: [polybar](https://github.com/polybar/polybar)
* Color theme: [onedark](https://github.com/joshdick/onedark.vim)
* Window manager: [bspwm](https://github.com/baskerville/bspwm)
* Display manager: [lightdm](https://wiki.archlinux.org/index.php/LightDM)

This repository contains the following directories:

* `bin`: some scripts I use
* `cheatsheets`: some useful guides/cheatsheets I wrote
* `dotsmanager`: configuration files for the dotfiles manager script. It also
contains a `script` directory with scripts you may want to include when
running the dofiles manager.
* `files`: the actual dotfiles. This folder acts as the root directory in the
original system.
* `localinfo`: information about the system, like installed packages,
directory trees, system specs, and the script outputs from
`dotsmanager/scripts/*`.

I have a ridiculously over-engineered script named `dotsmanager.bash` to
manage my dotfiles between multiple computers, for the sake of learning
scripting and for fun. It's also useful because I have multiple computers and
it makes it easy to have the same setup everywhere. You might be better off
using some tool like [stow
](https://alexpearce.me/2016/02/managing-dotfiles-with-stow/) or just [git
](https://link.medium.com/iNwwQ5EXw9). The Arch Linux wiki itself has a
[very useful article about this
](https://wiki.archlinux.org/index.php/Dotfiles).

If you are importing my dotfiles, do a `grep -r '[REMOVED]'`, which are parts
that have been manually removed for privacy reasons. Just replace these with
whatever you need.
