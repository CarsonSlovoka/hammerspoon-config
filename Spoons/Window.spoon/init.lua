local M = {}

local function imgFrom(name)
  -- https://github.com/CarsonSlovoka/hammerspoon-config/tree/3ebc93f/assets/img
  local path = os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. name
  if hs.fs.displayName(path) then
    -- print(path)
    return hs.image.imageFromPath(path)
  end
  return nil
end


---@param opt table?
function M.selectWindow(opt)
  opt = opt or {}
  local list = {}
  for _, win in ipairs(hs.window.allWindows()) do
    local appName = win:application():name()
    table.insert(list, {
      win = win,
      text = win:title(),
      subText = appName,
      image = imgFrom(string.gsub(appName, " ", "") .. ".icns")
    })
  end
  local chooser = hs.chooser.new(function(choice)
    if not choice then return end
    choice.win:focus()
  end)
  chooser:searchSubText(opt.searchSubText or false) -- 使得subText可以被
  -- Note: 當SubText定義為應用程式的名稱時，會很有用
  chooser:choices(list)
  chooser:show()
end

return M
