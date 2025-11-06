local mp = require("mp")
local utils = require("mp.utils")
local msg = require("mp.msg")

function set_sub_fonts_dir()
  local path = mp.get_property("path")
  if not path or path:match("Anime") == nil then return end
  msg.info("script: `auto-subfonts.lua` activated")

  -- 获取视频文件所在目录
  local dir = utils.split_path(path)

  -- 检查是否存在 sub-fonts 文件夹
  local sub_fonts_dir = utils.join_path(dir, "fonts")
  local sub_fonts_exists = utils.file_info(sub_fonts_dir)
  if sub_fonts_exists and sub_fonts_exists.is_dir then
    -- 设置字幕字体目录
    mp.set_property("sub-fonts-dir", sub_fonts_dir)
    msg.info("Loaded sub-fonts from: " .. sub_fonts_dir)
  else
    msg.info("No sub-fonts folder `fonts` found in: " .. dir)
  end
end

-- 在文件加载时运行
mp.register_event("file-loaded", set_sub_fonts_dir)
