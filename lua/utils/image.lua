local M = {}

--- @class Image

---@param imgName string
---@return Image|nil
function M.fromPath(imgName)
  return hs.image.imageFromPath(os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. imgName)
end

---@param appName string
---@return Image|nil
function M.fromSystemApp(appName)
  return hs.image.imageFromPath(string.format("/System/Applications/%s/Contents/Resources/AppIcon.icns", appName)) or
      hs.image.imageFromPath(string.format("/System/Applications/%s/Contents/Resources/AppIconLoc.icns", appName)) -- 本地化的icns
end

---@param name string png, @2x.png, icns, ...
---@return Image|nil
function M.fromDockApp(name)
  return hs.image.imageFromPath("/System/Library/CoreServices/Dock.app/Contents/Resources/" .. name)
end

return M
