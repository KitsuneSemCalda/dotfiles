-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.smarttab = true
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.mouse = ""
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_module/*" })
