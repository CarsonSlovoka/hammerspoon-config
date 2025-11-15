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
---@param layouts table {{name, layout, lanuchOrFocus}, ...}
function M:add(name, layouts)
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
        if not hs.application.launchOrFocus(appName) then
          -- 如果打開失敗，嘗試將其視為bundleID, 以bundleID嘗試開啟
          local bundleID = appName
          hs.application.open(bundleID)
        end
      end
    end
  end
end

--- 綁定一個layout熱鍵, 觸發後可再透過1 .. n 來切換layout, 如此可以節省全域的熱鍵綁定
function M:bind(mods, key)
  -- if #M.layoutFuncMap == 0 then -- map不能用這樣，得到的都會是nil
  if next(M.layoutFuncMap) == nil then
    hs.alert.show(
      "⚠️ [Layout.spoon] `spoon.Layout:bind` will have no effect, please make sure bindLayoutManager is triggered after `spoon.Layout:add` is defined",
      10)
    return
  end
  local mKey = hs.hotkey.modal.new(mods, key)

  function mKey:entered()
    mKey.verbose = true -- 新增一個自定義的屬性

    -- local style = {
    --   textSize = 18,
    --   atScreenEdge = 1, -- top
    -- }
    local msg = ""
    local i = 1
    for layoutName, layoutFunc in pairs(M.layoutFuncMap) do
      msg = msg .. string.format("\n%d  %s", i, layoutName)
      -- mKey:bind() -- 放在裡面不好，這等同於entered之後才會開始定義，可能會沒那麼即時能用

      i = i + 1
    end
    -- hs.alert.show(msg, nil, nil, 10)
    hs.alert.show(msg, 3)
  end

  local i = 1
  for _, layoutFunc in pairs(M.layoutFuncMap) do
    mKey:bind(
      {}, tostring(i), -- mods, key
      nil,             -- msg
      function()
        layoutFunc()
        mKey.verbose = false
        mKey:exit()
      end
    )
    i = i + 1
  end

  function mKey:exited()
    if mKey.verbose then
      hs.alert.show("🔚 exit layout manager", 3.0)
    end
  end

  mKey:bind({}, 'escape', function()
    mKey:exit()
  end)
end

return M
