# KitsuneSemCalda Neovim

This configuration is inspired by ["Takuya" dotfiles](https://www.devas.life/effective-neovim-setup-for-web-development-towards-2024/) with my special touch to my workflow.

Because my primary programming language is Golang and Typescript is my language of the year.

Tecnologies like react, react-native and electron can't be much performatic but is a good quick-development tools.

---

# Configuration

- Theme: [Lunarvim/Onedarker](https://github.com/LunarVim/onedarker.nvim)

It's a very good and simple theme inspired in old atom colorscheme.

- Keymap List:

1.  `+` being a keymap to increment a number in editor
2.  `-` being a keymap to decrement a number in editor
3.  `dw` being a keymap to delete a backward word
4.  `ctrl + a` being a keymap to select all text
5.  `ctrl + j` being a keymap to jump from diagnostic

This is a very short number of keymap but is good enough from any project than i make.
Any issue can be fixed with `shift + k` (pick) and `ctrl + j` (diagnostic)

- Auto Commands:

  - Turn off paste mode when leaving insert

    This autocmd disable the paste when leaving of insert mode

  - Disable the concealing in some file formats

    This autocmd disable the concealing level in {Json and Mardown}

- Plugins:

  - Mason LSP:

    - html-lsp
    - htmlhint
    - htmlbeautifier
    - htmx-lsp
    - css-lsp
    - css-variables-language-server
    - cssmodules-language-server

  - Lazy Plugins:
    - Dap Core
    - Dap Lua Adapter
    - Prettier
    - Eslint
    - Golang
    - Typescript
    - Json
    - TailwindCss
    - None-ls
    - dot
    - mini-hipatterns
    - refactoring
