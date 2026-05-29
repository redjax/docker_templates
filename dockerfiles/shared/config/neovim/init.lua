-- Use native package path separator
local sep = package.config:sub(1, 1)

-- Load your main config module (config/init.lua) for all shared config
require("config")
