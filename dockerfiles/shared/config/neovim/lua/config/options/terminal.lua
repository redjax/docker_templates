-- Terminal colors
local function set_term_colors()
  -- Check $COLORTERM for 'truecolor' or '24bit'
  local colorterm = os.getenv("COLORTERM") or ""
  local term = os.getenv("TERM") or ""
  local supports_truecolor = false

  -- Most terminals that support true color set COLORTERM to 'truecolor' or '24bit'
  if colorterm:lower():find("truecolor") or colorterm:find("24bit") then
    supports_truecolor = true
  end

  -- Some terminals may not set COLORTERM, but TERM may be set to something like 'xterm-truecolor'
  if term:lower():find("truecolor") then
    supports_truecolor = true
  end

  if supports_truecolor then
    vim.opt.termguicolors = true
  end
end

set_term_colors()

-- Shell
if vim.g.platform == "windows" then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
end
