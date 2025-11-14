local M = {
  layoutFuncMap = {} -- 此用處可參考: https://github.com/CarsonSlovoka/hammerspoon-config/commit/0f34ef09#diff-eaab8cac4014c5ebcb0e60cacb453a1fe5a00bcb5c7d26dd01e8891c967ffbecR71-R75
}


--- 如果視窗縮小的情況下，它沒辦法再叫出來
local function focusIfLaunched(appName)
  local app = hs.application.get(appName)
  if app then
    app:activate()
  end
end

--- 只要是該app的所有視窗，它們的layout都會調整
local function adjustWindowsOfApp(appName, gridSettings)
  -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/application.lua
  local app = hs.application.get(appName)
  local wins
  if app then
    -- https://www.hammerspoon.org/docs/hs.window.html#allWindows
    wins = app:allWindows()
  end
  if wins then
    for _, win in ipairs(wins) do
      hs.grid.set(win, gridSettings)
    end
  end
end


---@param name string
---@param mods table  {"cmd"}
---@param key string
---@param layouts table {{name, layout, lanuchOrFocus}, ...}
function M:defineLayout(name, mods, key, layouts)
  -- 使得如果不想要依靠bind來觸發，也有途徑來觸發
  M.layoutFuncMap[name] = function()
    -- 👇 用起來怪怪的🤔
    -- -- 先將所有視窗最小化, 避免成品中還有其它的視窗甘擾
    -- for _, win in ipairs(hs.window.allWindows()) do
    --   win:minimize()
    -- end

    hs.alert.show("Layout: " .. name)
    for _, obj in ipairs(layouts) do
      local appName = obj[1]
      local layout = obj[2]
      local lanuchOrFocus = obj[3]
      if lanuchOrFocus == nil then
        lanuchOrFocus = true
      end

      adjustWindowsOfApp(appName, layout)

      if lanuchOrFocus then
        -- focusIfLaunched(appName)
        hs.application.launchOrFocus(appName)
      end
    end
  end
  hs.hotkey.bind(mods, key, M.layoutFuncMap[name])
end

return M
