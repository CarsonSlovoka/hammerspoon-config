local M = {}

--- @class Image

---@param imgName string
---@return Image
function M.fromPath(imgName)
  return hs.image.imageFromPath(os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. imgName)
end

---@param appName string
---@return Image
function M.fromSystemApp(appName)
  return hs.image.imageFromPath(string.format("/System/Applications/%s/Contents/Resources/AppIcon.icns", appName))
end

return M
