local M = {}

local function imgFrom(name)
  -- https://github.com/CarsonSlovoka/hammerspoon-config/tree/3ebc93f/assets/img
  local path = os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. name
  if hs.fs.displayName(path) then
    print(path)
    return hs.image.imageFromPath(path)
  end
  return nil
end

function M.selectWindow()
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
  chooser:choices(list)
  chooser:show()
end

return M
