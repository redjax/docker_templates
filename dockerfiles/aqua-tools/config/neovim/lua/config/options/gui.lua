-- Enable syntax highlighting
vim.cmd('syntax enable')

-- GUI font settings
if vim.g.platform == "windows" then
  vim.opt.guifont = "FiraCode Nerd Font:h11"
elseif vim.g.platform == "mac" then
  vim.opt.guifont = "FiraCode Nerd Font:h12"
else
  vim.opt.guifont = "FiraCode Nerd Font:h10"
end
