## Movement
* `h`, `j`, `k`, `l` for **movement** (left, down, up, right).
* `w`, `e` to move to the beginning or end of the **next word**. `b` to move to the beginning of the **previous word**. Uppercased, special characters like commas will be skipped (not spaces). `W` and `E` will do the same with **WORDS** (skips special characters)
* *Note:* you can type a number before these commands to **repeat** them. `2j` goes to the letter 2 positions to the left. It can be done with text too if you type `i+<esc>` after writing the text desired.
* `a` enters insert mode after the cursor. `A` to insert into the end of a line, `I` to insert it at the beginning of the line.
* `{` or `}` to go to the start or end of a **block**.
* `%` jumps from a **parenthesis**/similar to the the other (`)`,`]`,`}`).
* `]c` jumps to the next **git-gutter change**, and `[c` to the previous one.
* `gn` jumps to the next **Coc-Nvim diagnostic**, and `gN` to the previous one.
* `gd` jumps to the **function/type definition**, and `gr` jumps to the first reference.

## Selecting and editing
* `V` selects an entire line, `v` starts a **selection**. `Ctrl+v` selects blocks instead. `o` moves the cursor to the other end of the selection. To insert text, select, press `Shift+i` and insert it.
* `y` to **copy** the selection, `d` to **cut** it, `p` to **paste** after the cursor. `P` pastes before. `x` cuts a single character. `r` to replace a single character. `c` will delete the character (or word with `ce`) and enter insert mode.
* `d` or `y` followed by `aw` will do the action the current word. `D` will delete from the cursor to the end of line.
* `>` or `<` after selecting a block will increase or decrease its indentation by 1. This can be done repeatedly if a number is input before, like `5>`
* `o` opens a line below and enters insert mode. `O` does the same but above the current line.

## Finding
* `/` followed by a word will find its following **occurences** in the file and `?` the previous. `n` goes to the next result and `N` to the previous one.
* `:%s/foo/bar/g` will **replace** all `foo` occurrences for `bar`. Flags: `c` to confirm, `g` for global results (not only the first is changed), `i` for case insensitive and the `%` at the beginning is to replace in the entire file instead of the current line.

## Undo and redo
* `u` **undos** the last changes.
* `Ctrl+r` **redos** the last undo.

## Splits
`Ctrl+w` starts **"Tab mode"**. You can press the following keys afterwards:

* `w` **cycles** between tabs. Spamming `Ctrl+w` also works.
* `h`, `j`, `k`, `l` to **move** to the left, down, up or right tab.
* `c` to **close** a tab.
* `T` to move it to a **new** full-window tab. `:tab sp` to copy it instead.

* `:res <lines>` to resize a tab. If on a terminal, `Ctrl+W` opens the vim commands.

## Tabs
NERDTree can open files in new tabs with `t`, and fugitive with `O`.

* `:tabedit` or `:tabe` to open a new tab with a file
* `gt` to go to next tab, `gT` to the previous one, and `{i}gt` to the `i`th.
* `Ctrl+PgUp` and `Ctrl+PgDown` are the same, respectively.

## Macros
* `qa` starts recording macro 'a'. `q` stops recording. `@a` will play the macro 'a', `@:` will play the last macro.

## NERDTree
* `o` **opens** the file.
* `i` opens the file in **splitscreen**.
* `s` opens the file in **vertical** splitscreen.

## Other functionalities
* `:set spell spelllang=LANG` will enable the spellchecking, where `LANG` can be any code like `en_us` or `es`.

## Custom keys and commands
* `:QuickHelp` will open this help file.
* `:CopyDir` will copy the current file directory to the clipboard.
* `+` will open a new **terminal** at the file's directory.
* `,c` will **toggle-comment** the line with NERDCommenter.
* `,t` will open a **vim terminal** at the bottom (shortcut for `:Term`).
* `,r` will **refresh** the current file.
* `,i` will switch between **indentation** configurations. `,l` will switch between the **column hint** length configurations (79 and 120). `,n` will toggle the **column numbers**.
