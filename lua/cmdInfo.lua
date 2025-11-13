local name = {
  hammerspoonReload = "hammerspoon reload",
  listHsImage = "list hs.image",
  showClock = "show clock",
  openBrowser = "open browser",
  openDir = "open dir",
  layoutLeftKittyRightFirefox = "layout {l: kitty, r: firefox}",
  showGrid = "show grid",
  fullscreenAllWindow = "fullscreenAllWindow",
}

local cmdTable = {
  [name.hammerspoonReload] = function()
    hs.reload()
  end,
  [name.listHsImage] = function()
    print(hs.image.systemImageNames)
    -- local searchIcon = hs.image.imageFromName("NSSearchFieldTemplate") -- 載入搜尋圖示
  end,
  [name.showClock] = function()
    spoon.AClock:toggleShow()
  end,
  [name.openBrowser] = function(kargs)
    -- local cmd = "firefox --window --new-tab " .. kargs.url -- ❌ 需要絕對路
    local cmd = "/opt/homebrew/bin/firefox --window --new-tab " .. kargs.url
    os.execute(cmd)
    -- hs.task.new("/bin/bash", nil, { "-c", cmd }):start()
    -- hs.osascript.applescript(string.format('do shell script "%s"', cmd))
  end,
  [name.openDir] = function(kargs)
    os.execute("open " .. kargs.path)
  end,
  [name.layoutLeftKittyRightFirefox] = function()
    local splitLayout = {
      { "kitty",   nil, nil, hs.layout.left50,  nil, nil },
      { "Firefox", nil, nil, hs.layout.right50, nil, nil }
    }

    local keepApps = {
      -- Caution: 名稱大小寫有差異
      ["kitty"]   = true,
      ["Firefox"] = true
    }

    -- 之後把除 keepApps 裡面指定的 App 之外的所有視窗都 hide
    for _, win in ipairs(hs.window.allWindows()) do
      local appName = win:application():name()
      if keepApps[appName] then
        -- 確保如果這些視窗是縮小時，也可以被叫上來，不然layout沒做用
        hs.application.launchOrFocus(string.format("/Applications/%s.app", appName))
      else
        -- 避免其它視窗干擾
        -- print(appName)
        win:minimize()
      end
    end

    hs.layout.apply(splitLayout)
  end,
  [name.showGrid] = function()
    -- hs.grid.setMargins(hs.geometry.size(0, 0))
    -- hs.grid.setGrid('8x2') -- 預設是3x3, 可以不設定直接用 hs.grid.show() 就可曉得了, 也可以`hs.grid.getGrid(hs.screen.mainScreen())`來得知
    hs.grid.show()
    -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/grid.lua
    -- hs.grid.set(hs.window.focusedWindow(), '4,0 4x2') -- 如果整個的grid是8x2, 則4,0 4x2 就是移動到4,0的位置，然後它的大小有4x2那麼大，因此就是佔滿整個右
  end,

  [name.fullscreenAllWindow] = function()
    -- hs.grid.getGrid(hs.screen.mainScreen()) -- hs.geometry.size(3,3)
    -- hs.grid.getGridFrame(hs.screen.mainScreen()) -- hs.geometry.rect(0.0,31.0,1920.0,1049.0)
    local mainScreen = hs.screen.mainScreen()
    local grid = hs.grid.getGrid(mainScreen)
    for i, win in ipairs(hs.window:allWindows()) do
      hs.grid.set(win, string.format('0,0 %sx%s', grid.w, grid.h))
    end
  end
}

return {
  cmdTable = cmdTable,
  name = name,
}
