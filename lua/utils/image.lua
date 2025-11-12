local M = {}

--- @class Image

---@param imgName string
---@return Image
function M.getImage(imgName)
  return hs.image.imageFromPath(os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. imgName)
end

return M
