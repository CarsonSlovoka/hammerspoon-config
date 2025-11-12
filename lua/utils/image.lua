local M = {}

--- @class Image

---@param imgName string
---@return Image
function M.fromPath(imgName)
  return hs.image.imageFromPath(os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. imgName)
end

return M
