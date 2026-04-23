-- Detects the platform Neovim is running in and sets global vars.
-- To use these variables in another Lua script, you can do something like:
--   if vim.g.platform == "linux" then
--     Linux-specific config here
--    end

local uname = vim.loop.os_uname()
local os_name = uname.sysname
local os_release = uname.release
local os_version = uname.version

-- Normalize OS name for convenience
local platform
if os_name == "Darwin" or (jit and jit.os == "OSX") then
  platform = "mac"
elseif os_name == "Linux" then
  platform = "linux"
elseif os_name == "Windows_NT" or (jit and jit.os == "Windows") then
  platform = "windows"
else
  platform = os_name:lower()
end

-- Detect Linux distribution
local distro = nil
if platform == "linux" then
  local f = io.open("/etc/os-release", "r")
  if f then
    for line in f:lines() do
      local k, v = line:match('^([%w_]+)=(.+)$')
      if k == "ID" then
        distro = v:gsub('"', '')
        break
      end
    end
    f:close()
  end
end

-- Set as global variables
vim.g.platform = platform
vim.g.os_name = os_name
vim.g.os_release = os_release
vim.g.os_version = os_version
vim.g.linux_distro = distro

return {
  platform = platform,
  os_name = os_name,
  os_release = os_release,
  os_version = os_version,
  linux_distro = distro,
}
