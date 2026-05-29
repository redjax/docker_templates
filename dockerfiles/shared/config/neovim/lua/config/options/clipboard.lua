-- Example: Set <leader>c to copy to clipboard, platform-specific

if vim.g.platform == "windows" then
  -- Windows-specific keybinding (uses "+y" for clipboard)
  vim.keymap.set({'n', 'x'}, '<leader>c', '"+y', { desc = "Copy to clipboard (Windows)" })
elseif vim.g.platform == "mac" then
  -- macOS-specific keybinding (uses pbcopy if you want, or "+y")
  vim.keymap.set({'n', 'x'}, '<leader>c', '"+y', { desc = "Copy to clipboard (macOS)" })
elseif vim.g.platform == "linux" then
  -- Linux-specific keybinding (uses "+y", requires xclip or wl-clipboard)
  
  vim.o.clipboard = "unnamedplus"

  vim.keymap.set({'n', 'x'}, '<leader>c', '"+y', { desc = "Copy to clipboard (Linux)" })

  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
else
  -- Fallback/default
  vim.keymap.set({'n', 'x'}, '<leader>c', '"+y', { desc = "Copy to clipboard (default)" })
end
