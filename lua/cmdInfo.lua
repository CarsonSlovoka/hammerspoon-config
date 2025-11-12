local name = {
  hammerspoonReload = "hammerspoon reload",
  listHsImage = "list hs.image",
  showClock = "show clock",
  openBrowser = "open browser",
  openDir = "open dir",
  layoutLeftKittyRightFirefox = "layout {l: kitty, r: firefox}",
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
}

return {
  cmdTable = cmdTable,
  name = name,
}
