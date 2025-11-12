local M = {}

---@param imgName string
---@return string
function M.getImage(imgName)
  return os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. imgName
end

return M
