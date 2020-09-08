## Some changes made after the Arch installation

* Install [yay](https://github.com/Jguer/yay)

* A run with `reflector` for an optimal mirrorlist

* Install all the listed programs in `localinfo/installed.txt`

* Import the dotfiles into the system

* `pacman -S base base-devel`

* `chsh -s "$(which zsh)"`

* Set up megasync excluded patterns:

```
.git
.vim
desktop.ini
__pycache__
*.o
*.so
.venv
*.a
a.out
```

* Configure makepkg in `/etc/makepkg.conf`:

```ini
MAKEFLAGS="-j$(($(nproc) + 1))"
```

* Uncomment some lines in `/etc/pacman.conf`:

```ini
Color
```

```ini
[community]
Include = /etc/pacman.d/mirrorlist
```

* Installation of IDEs in `/opt`

* Defaults handlers:

```commandline
$ xdg-mime default firefox.desktop x-scheme-handler/http
$ xdg-mime default firefox.desktop x-scheme-handler/https
```

* Activate some services:
    * `ntpd` to synchronize the time
