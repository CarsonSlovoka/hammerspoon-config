local name = {
  hammerspoonReload = "hammerspoon reload",
  listHsImage = "list hs.image",
  showClock = "show clock",
  openBrowser = "open browser",
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
  end
}

return {
  cmdTable = cmdTable,
  name = name,
}
