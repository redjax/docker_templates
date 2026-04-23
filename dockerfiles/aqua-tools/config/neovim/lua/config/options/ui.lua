-- Show line numbers
vim.opt.number = true
-- Show relative line numbers
vim.opt.relativenumber = false

-- Mouse support
vim.opt.mouse = "a"

-- UI tweaks
vim.opt.cursorline = true
-- vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Display invisible characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Show live preview of things like search & replace
vim.opt.inccommand = 'split'

-- Dark/light mode
vim.opt.background = 'dark'
