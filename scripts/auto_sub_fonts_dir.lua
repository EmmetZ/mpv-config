--[[
Documentation: None

Automatically load fonts temporarily
Check if a 'fonts' folder exists in the current playback directory and dynamically modify --sub-fonts-dir

SOURCE_ https://github.com/hooke007/MPV_lazy/blob/main/portable_config/scripts/auto_sub_fonts_dir.lua
]]

local mp = require "mp"
mp.options = require "mp.options"
mp.utils = require "mp.utils"

local user_opt = {
    load = true,
}
mp.options.read_options(user_opt)

if user_opt.load == false then
    mp.msg.info("Script has been disabled by initial configuration")
    return
end
-- Reason: The first version that added the --sub-fonts-dir option
local min_major = 0
local min_minor = 36
local min_patch = 0
local mpv_ver_curr = mp.get_property_native("mpv-version", "unknown")
local function incompat_check(full_str, tar_major, tar_minor, tar_patch)
    if full_str == "unknown" then
        return true
    end

    local clean_ver_str = full_str:gsub("^[^%d]*", "")
    local major, minor, patch = clean_ver_str:match("^(%d+)%.(%d+)%.(%d+)")
    major = tonumber(major)
    minor = tonumber(minor)
    patch = tonumber(patch or 0)
    if major < tar_major then
        return true
    elseif major == tar_major then
        if minor < tar_minor then
            return true
        elseif minor == tar_minor then
            if patch < tar_patch then
                return true
            end
        end
    end

    return false
end
if incompat_check(mpv_ver_curr, min_major, min_minor, min_patch) then
    mp.msg.warn("Current mpv version (" .. (mpv_ver_curr or "unknown") .. ") is lower than " .. min_major .. "." .. min_minor .. "." .. min_patch .. ", font directory feature has been disabled.")
    return
end

local fonts_dir_init = mp.get_property_native("sub-fonts-dir")
local fonts_dir_cur = fonts_dir_init
function update_fonts_dir()
    local path = mp.get_property_native("path")
    local fonts_dir = path:match("(.*[/\\])") .. "fonts"
    if fonts_dir == fonts_dir_cur or fonts_dir == fonts_dir_init then
        return
    end
    local read_success = mp.utils.readdir(fonts_dir)
    if not read_success then
        mp.set_property("sub-fonts-dir", fonts_dir_init)
        fonts_dir_cur = fonts_dir_init
        mp.msg.info("Reverted --sub-fonts-dir to initial value")
    else
        mp.set_property("sub-fonts-dir", fonts_dir)
        fonts_dir_cur = fonts_dir
        mp.msg.info("Set --sub-fonts-dir to new value [" .. fonts_dir .. "]")
    end
end

mp.register_event("start-file", update_fonts_dir)
