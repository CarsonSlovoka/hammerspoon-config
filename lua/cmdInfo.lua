local name = {
  hammerspoonReload = "hammerspoon reload",
  listHsImage = "list hs.image",
  showClock = "show clock",
  runAppleScript = "run apple script",
  openBrowser = "open browser",
  openDir = "open dir",
  tellFinder = "tell application Finder ...",
  layoutLeftKittyRightFirefox = "layout {l: kitty, r: firefox}",
  selectLayout = "select layout",
  showGrid = "show grid",
  fullscreenAllWindow = "fullscreenAllWindow",
  minimizeAllWindow = "minimizeAllWindow",
  listRunningApplications = "runningApplications",
  whichKey = "whichKey",
  preview = "preview",
  splitVideo = "splitVideo",
  toggleDock = "toggleDock",
  setVolume = "setVolume",
}

local browserManager = {}


local function split_by_space(str)
  local results = {}
  -- "%S+" matches one or more non-whitespace characters
  for word in string.gmatch(str, "%S+") do
    table.insert(results, word)
  end
  return results
end

---@param windowName table|string
---@param browserName string
---@return boolean isFocus
function browserManager.focusWindow(windowName, browserName)
  -- 定義常見的 Firefox 窗口標題模式
  local patterns = {
    ["gmail"] = "Gmail",
    ["discord"] = "Discord",
    ["youtube"] = "YouTube",
    ["github"] = "GitHub"
  }

  ---@type table
  local windowNames
  if type(windowName) == "string" then
    windowNames = { windowName }
  else
    windowNames = windowName
  end

  -- 嘗試先找到現有的窗口
  local existingWindow = nil


  for _, win in ipairs(hs.window.allWindows()) do
    if win:application():name() == browserName then
      local title = win:title() -- 等同在menu bar對Firefox右鍵所看到的名稱

      for _, winName in ipairs(windowNames) do
        local targetPattern = patterns[string.lower(winName)] or winName
        if string.find(string.lower(title), string.lower(targetPattern)) then
          existingWindow = win
          break
        end
      end

      if existingWindow then
        break
      end
    end
  end

  if existingWindow then
    existingWindow:focus()
    -- print("Focused on existing Firefox window")
    return true
  else
    return false
  end
end

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
    -- 獲取當前預設瀏覽器的 Bundle ID
    local defaultHandler = hs.urlevent.getDefaultHandler('http')

    local firefoxID = "org.mozilla.firefox"
    local safariID = "com.apple.Safari"

    local exec_func
    if defaultHandler == firefoxID then
      exec_func = function()
        -- local cmd = "firefox --window --new-tab " .. kargs.url -- ❌ 需要絕對路
        -- local cmd = "/opt/homebrew/bin/firefox --window --new-tab " .. kargs.url -- 可行但不是單獨的視窗
        local cmd = "/opt/homebrew/bin/firefox --new-window " .. kargs.url .. " & "
        -- Warn: 用--new-window必須在後面使用&不然會鎖住，等同hammerspoon需要等視窗關閉才可以再動作
        os.execute(cmd)
        -- hs.task.new("/bin/bash", nil, { "-c", cmd }):start()
        -- hs.osascript.applescript(string.format('do shell script "%s"', cmd))
      end
    else
      exec_func = function()
        -- 對於 Safari/Chrome，直接用系統 open 指令或 HS API 最穩
        -- hs.urlevent.openURL 會直接使用預設瀏覽器開啟
        hs.urlevent.openURL(kargs.url)
      end
    end

    if kargs.windowName == nil then
      exec_func()
      return
    end

    if not browserManager.focusWindow(kargs.windowName, defaultHandler == firefoxID and "Firefox" or "Safari") then
      -- 失敗了話，就嘗試開新視窗後再試一次
      exec_func()
      hs.timer.doAfter(2, function()
        browserManager.focusWindow(kargs.windowName, defaultHandler == firefoxID and "Firefox" or "Safari")
      end)
    end
  end,
  [name.openDir] = function(kargs)
    os.execute("open " .. kargs.path)
  end,
  [name.tellFinder] = function(kargs)
    hs.osascript.applescript(string.format([[
        tell application "Finder"
            activate
            -- open xxx
            %s
        end tell
    ]], kargs.cmd))
    -- hs.application.open("com.apple.finder") -- 可在apple script中用activate即可
  end,
  [name.runAppleScript] = function(kargs)
    -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/osascript.lua
    --- Returns:
    ---  * A boolean value indicating whether the code succeeded or not
    ---  * An object containing the parsed output that can be any type, or nil if unsuccessful
    ---  * If the code succeeded, the raw output of the code string. If the code failed, a table containing an error dictionary
    -- local ok, err, tableDesc = hs.osascript.applescript(kargs.script)
    local ok = hs.osascript.applescript(kargs.script)
    if ok and kargs.ok_msg then
      hs.alert.show(kargs.ok_msg)
    elseif kargs.err_msg then
      hs.alert.show(kargs.err_msg or "")
    end
    -- hs.alert.show(kargs.test or "") -- 空訊息會有空的訊息框，還是看的到
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
  [name.selectLayout] = function(kargs)
    -- ~/.Hammerspoon/Spoons/Layout.spoon/init.lua
    local layout = spoon.Layout:get(kargs.name)
    if layout then
      layout.func()
    end
  end,

  [name.fullscreenAllWindow] = function()
    -- hs.grid.getGrid(hs.screen.mainScreen()) -- hs.geometry.size(3,3)
    -- hs.grid.getGridFrame(hs.screen.mainScreen()) -- hs.geometry.rect(0.0,31.0,1920.0,1049.0)
    local mainScreen = hs.screen.mainScreen()
    local grid = hs.grid.getGrid(mainScreen)
    for i, win in ipairs(hs.window:allWindows()) do
      hs.grid.set(win, string.format('0,0 %sx%s', grid.w, grid.h))
    end
  end,
  [name.minimizeAllWindow] = function()
    for _, win in ipairs(hs.window.allWindows()) do
      win:minimize()
    end
  end,
  [name.listRunningApplications] = function()
    local msg = ""
    for _, app in ipairs(hs.application.runningApplications()) do
      msg = msg .. "\n" .. string.format("%s | %s", app:name(), app:bundleID())
    end

    -- Tip: style, 在檔案: /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/alert.lua
    --   搜尋: module.defaultStyle 可以看到預設的設定
    local style = {
      textSize = 12,
      atScreenEdge = 1, -- 0: center (default); 1: top ; 2: bottom
    }

    -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/alert.lua
    -- hs.alert.show(msg, style, hs.screen.mainScreen(), 5)
    -- hs.alert.show(msg, 10)

    print(msg) -- 在hammerspoon中查看
    hs.application.launchOrFocus("/Applications/Hammerspoon.app")
  end,

  [name.whichKey] = function()
    hs.alert.show("press `Esc` key to stop", { atScreenEdge = 1 }, nil, 5)

    local keyEvent = hs.eventtap.new(
      {
        -- 要監聽的類型
        hs.eventtap.event.types.keyDown,
        -- hs.eventtap.event.types.keyUp
      },
      function(e)
        local code = e:getKeyCode()
        -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/keycodes.lua
        local keyStr = hs.keycodes.map[code]
        -- local isDown = (e:getType() == hs.eventtap.event.types.keyDown) -- 如果只有監聽keyDown而已，就不需要多此一舉, 這都是true
        local msg = string.format(
          "key code: %s \n" ..
          "key name: %s",
          code, keyStr
        )
        print(msg)
        hs.alert.show(msg)
        return false -- false繼續原本的動作, true會阻檔原本的動作
      end
    )
    keyEvent:start()

    local bindKey = {}
    -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/hotkey.lua
    -- 綁定一個暫時的esc鍵，來取消監看
    bindKey.esc = hs.hotkey.bind({ "" }, "escape", function()
      keyEvent:stop()
      bindKey.esc:delete() -- 刪除此esc綁定鍵
      hs.alert.show("stop watch")
    end)

    -- hs.timer.doAfter(5, function() end)
  end,
  [name.preview] = function(kargs)
    local searchDirs = kargs.searchDirs or { "~/Downloads/", "~/Desktop/" }
    local exts = ""
    for _, ext in ipairs(kargs.exts) do
      exts = exts .. " -e " .. ext
    end

    spoon.Fd:chooser(function(selection)
        if selection then
          hs.execute('open "' .. selection.fullpath .. '"')
        end
      end,
      searchDirs, -- { "~/Downloads/", "~/Desktop/" },
      exts        -- "-e mp4 -e mov"
    )
  end,
  [name.splitVideo] = function(kargs)
    local exts = ""
    for _, ext in ipairs(kargs.exts) do
      exts = exts .. " -e " .. ext
    end

    spoon.Fd:chooser(function(selection)
        if selection then
          local cmd = string.format(
            "bash ~/sh/split_mp4.sh %s %d",
            selection.fullpath, kargs.n
          )
          local ext = string.match(selection.fullpath, "%.([^.]+)$")
          print(cmd)
          -- hs.execute(cmd)
          hs.execute(cmd, true)              -- 需要載入環境變數 -- hs.execute的工作目錄預設是 ~/.hammerspoon/
          hs.execute("open ~/.hammerspoon/") -- 開啟產出的目錄
          local output = hs.execute("ls -lht ~/.hammerspoon/*." .. ext)
          hs.alert.show(output, 5)
        end
      end,
      kargs.searchDirs or { "~/Downloads/", "~/Desktop/" },
      exts, -- "-e mp4 -e mov"
      {
        placeholderText = "bash split_mp4.sh <filepath> 1"
      }
    )
  end,
  [name.toggleDock] = function()
    local result = hs.execute("defaults read com.apple.dock autohide")
    local isHidden = result:match("1") ~= nil

    -- if isHidden then
    --   -- 如果目前是隱藏，則設為顯示
    --   hs.execute("defaults write com.apple.dock autohide -bool false")
    -- else
    --   -- 如果目前是顯示，則設為隱藏
    --   hs.execute("defaults write com.apple.dock autohide -bool true")
    -- end
    -- -- 重啟 Dock 使設置生效
    -- hs.execute("killall Dock") -- Warn: 重啟會有點慢

    -- 使用 AppleScript 直接切換，無需重啟 Dock
    local script = [[
        tell application "System Events"
            tell dock preferences
                set autohide to not autohide
            end tell
        end tell
    ]]
    hs.osascript.applescript(script)

    -- 顯示通知
    local status = isHidden and "false" or "true"
    hs.alert.show("Dock autohide: " .. status, 3)
  end,
  [name.setVolume] = function(kargs)
    -- local chooser = kargs.self
    -- https://www.hammerspoon.org/docs/hs.chooser.html#query
    -- local input = chooser:query() -- Note: query 可以設定或者查詢當前chooser所輸入的內容
    -- -- hs.alert.show(input)
    -- local arr = split_by_space(input)
    -- local vol = tonumber(arr[#arr]) -- 以最後一個內容當成輸入的參數
    -- hs.alert.show(arr[#arr])

    local defaultOutputDevice = hs.audiodevice.defaultOutputDevice()
    local default = nil
    if defaultOutputDevice then
      default = defaultOutputDevice:outputVolume()
    end
    local selectBtn, val = hs.dialog.textPrompt("input number",
      string.format("🔈 set volume (%s%%)", tostring(default) or ""),
      "", -- default
      "OK", "Cancel",
      false
    ) -- Tip: 可以用tab來切換, 就能輸入了
    local vol = selectBtn == "OK" and tonumber(val) or nil
    -- local vol = tonumber(kargs.asks[1].value)
    if vol and vol >= 0 and vol <= 100 then
      hs.audiodevice.defaultOutputDevice():setVolume(vol)
      hs.alert.show("Custom volume:" .. vol .. "%")
    else
      hs.alert.show("Invalid input, please enter the number from 0-100.")
    end
  end
}

return {
  cmdTable = cmdTable,
  name = name,
}
