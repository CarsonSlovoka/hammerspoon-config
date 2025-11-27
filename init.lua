-- Tip: 如以下路徑加入: /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ 即可偵測到相關的定義
--   https://github.com/CarsonSlovoka/nvim/commit/9c603a8074
hs = hs -- 減少未定義的警告
spoon = spoon

local SOURCE_DIR = debug.getinfo(1).source:match("@?(.*/)")

-- local hammerspoon_config_dir = os.getenv("HOME") .. '/.hammerspoon/'
local hammerspoon_config_dir = SOURCE_DIR
package.path = package.path ..
    ';' .. hammerspoon_config_dir .. 'lua/?.lua'
-- hs.alert.show(package.path)
-- print(package.path)

-- local test = require("test")
local utils = require("utils.utils")
-- test.test()

-- https://www.hammerspoon.org/docs/hs.ipc.html#cliInstall
-- hs -c "hs.alert.show('Hello from nvim')"
-- Err: can't access Hammerspoon message port Hammerspoon; is it running with the ipc module loaded?
hs.ipc.cliInstall() -- 要安裝ipc才不會有以上錯誤 -- 當註解掉後，重新啟用, 再使用hs -c還是會遇到, 因此這不是一次性設定, 需寫在init.lua
-- ls -lh /opt/homebrew/bin/hs
-- /opt/homebrew/bin/hs -> /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
-- hs.ipc.cliInstall("/usr/local/bin") 做類似以下的事情
-- ln -s "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ipc/bin/hs" "/usr/local/bin/hs"
-- Tip: 跳轉到ipc.lua中找到cliInstall就會曉得它做的事情 /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ipc.lua


for _, plugin in ipairs({
  "Dock",
  "AClock",
  "LeftRightHotkey",
  "Frame",
  "Layout",
  "Toggle",
  "Window",
  "HomeEnd",
  "Fd",
}) do
  -- Spoons/<plugin>.spoon
  hs.loadSpoon(plugin)
end

spoon.LeftRightHotkey:start()
spoon.Frame:setup(
  { "cmd" }, "r",
  {
    resize_step = 100,
    move_step = 200
  }
)

-- 如此在它的終端機，可以直接使用
-- spoon.Dock.hideDock()

-- hs.hotkey.bind({ "alt" }, "R", function()
--   hs.reload()
-- end)

local cmdInfo = require("cmdInfo")

local imageFromPath = utils.image.fromPath

local LayoutName = {
  Code = "Code",
  AskAI = "Ask AI",
  CodeAndFirefox = "Code & Firefox",
  CodeAndPreview = "Code & Preview",
  Firefox = "Firefox",
  LmStudio = "LmStudio",
}

local fuzzelList = {
  {
    text = "Firefox",
    subText = "launchOrFocus",
    path = "/Applications/Firefox.app",
    image = imageFromPath("firefox.icns"),
    -- image = hs.image.imageFromPath(utils.image.getImage("firefox.svg")), -- ❌ 不能給svg
  },
  {
    text = "Kitty",
    subText = "launchOrFocus",
    path = "/Applications/kitty.app",
    image = imageFromPath("kitty.icns")
  },
  {
    text = "Safari",
    subText = "launchOrFocus",
    path = "/Applications/Safari.app",
    image = imageFromPath("safari.icns")
  },
  {
    text = "LmStudio",
    subText = "launchOrFocus",
    path = "/Applications/LM Studio.app/",
    image = imageFromPath("lmstudio.icns")
  },
  {
    text = "Calendar",
    subText = "launchOrFocus",
    path = "/System/Applications/Calendar.app/",
    image = imageFromPath("calendar.icns")
  },
  {
    text = "Calculator",
    subText = "launchOrFocus",
    path = "/System/Applications/Calculator.app",
    image = imageFromPath("calculator.icns")
  },
  {
    text = "Notes",
    subText = "launchOrFocus",
    bundleID = "com.apple.Notes",
    -- path = "/System/Applications/Notes.app",
    -- Note: 首次不論是用application.{open, launchOrFocus} 的方式，可能都會需要等待一回，如果要聚焦可能都需要調用兩次
    image = imageFromPath("note.icns")
  },
  {
    text = "freeform",
    subText = "launchOrFocus",
    path = "/System/Applications/Freeform.app", -- 無邊記, 拿來當成小畫家放圖好用
    image = hs.image.imageFromPath("/System/Applications/Freeform.app/Contents/Resources/AppIcon.icns")
  },
  {
    text = "facetime",
    subText = "launchOrFocus",
    path = "/System/Applications/Facetime.app",
    image = hs.image.imageFromPath("/System/Applications/Facetime.app/Contents/Resources/AppIcon.icns")
  },
  {
    text = "image playground", -- 需要開啟Apple Intelligence
    subText = "launchOrFocus",
    path = "/System/Applications/Image Playground.app/",
    image = hs.image.imageFromPath("/System/Applications/Image Playground.app/Contents/Resources/AppIcon.icns")
  },
  {
    text = "Hammerspoon",
    subText = "launchOrFocus",
    path = "/Applications/Hammerspoon.app",
    image = imageFromPath("hammer.icns")
  },
  {
    text = "github",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://github.com/",
      windowName = "GitHub",
    },
    image = imageFromPath("github.icns")
  },
  {
    text = "discord",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://discord.com/channels/@me",
      windowName = "Discord",
    },
    image = imageFromPath("discord.icns")
  },
  {
    text = "gmail",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://mail.google.com/mail",
      windowName = "Gmail",
    },
    image = imageFromPath("gmail.icns")
  },
  {
    text = "google sheet",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://docs.google.com/spreadsheets",
      windowName = { "Google Sheet", "Google 試算表" }
    },
    image = imageFromPath("google-sheet.icns")
  },
  {
    text = "g-earth",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://earth.google.com/web/@23.95095877,124.13425799,-4075.36033555a,7328573.7277472d,35y,0h,0t" }, -- 如果只給到web, 會需要自己再點
    image = imageFromPath("g-earth.icns")
  },
  {
    text = "g-map",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://www.google.com/maps" },
    image = imageFromPath("g-map.icns")
  },
  {
    text = "g-drive",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://drive.google.com/drive/home" },
    image = imageFromPath("g-drive.icns")
  },
  {
    text = "g-news",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://news.google.com/" },
    image = imageFromPath("g-news.icns")
  },
  {
    text = "google translate",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://translate.google.com" },
    image = imageFromPath("google-translate.icns")
  },
  {
    text = "g-photo",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://photos.google.com/" },
    image = imageFromPath("g-photo.icns")
  },
  {
    text = "notion",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://www.notion.so/" },
    image = imageFromPath("notion.icns")
  },
  {
    text = "grok",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://grok.com/",
      windowName = { "Grok" },
    },
    image = imageFromPath("grok.icns")
  },
  {
    text = "chatgpt",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://chatgpt.com/",
      windowName = { "ChatGPT" },
    },
    image = imageFromPath("chatgpt.icns")
  },
  -- {
  --   text = hs.styledtext.new(
  --     "Possibility",
  --     {
  --       font = { size = 30 },
  --       color = hs.drawing.color.definedCollections.hammerspoon.green
  --     }
  --   ),
  --   subText = "What a lot of choosing there is going on here!",
  --   image = hs.image.imageFromName("NSComputer"),
  -- },
  {
    text = "~/Downloads",
    subText = cmdInfo.name.openDir,
    cmdName = cmdInfo.name.openDir,
    kargs = { path = "~/Downloads" },
    image = imageFromPath("download-folder.icns"),
  },
  {
    text = "hammerspoon reload",
    -- cmd = function() hs.reload() end -- ❌ cannot be converted into a proper NSObject, 因此沒辦法直接用function, 只能額外用table去找對應要執行的函數
    cmdName = cmdInfo.name.hammerspoonReload,
  },
  {
    text = "find icons",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://macosicons.com" },
    image = imageFromPath("macosicons.com.icns")
  },
  {
    text = "show grid",
    cmdName = cmdInfo.name.showGrid,
    image = imageFromPath("grid.icns"),
  },
  {
    text = "fullscreen all window",
    cmdName = cmdInfo.name.fullscreenAllWindow,
    image = imageFromPath("fullscreen.icns"),
  },
  {
    text = "minmize all window",
    cmdName = cmdInfo.name.minimizeAllWindow,
    image = imageFromPath("empty.icns"),
  },
  {
    text = "list running applications",
    cmdName = cmdInfo.name.listRunningApplications,
    image = imageFromPath("application-folder.icns"),
  },
  {
    text = "which key",
    cmdName = cmdInfo.name.whichKey,
    image = imageFromPath("keyboard.icns"),
  },
  {
    text = "list hs.image",
    cmdName = cmdInfo.name.listHsImage,
  },
  {
    text = "show clock",
    cmdName = cmdInfo.name.showClock,
  },
  {
    text = "layout: code",
    subText = cmdInfo.name.selectLayout,
    cmdName = cmdInfo.name.selectLayout,
    kargs = { name = LayoutName.AskAI },
  },
  {
    text = "layout: ask ai",
    subText = cmdInfo.name.selectLayout,
    cmdName = cmdInfo.name.selectLayout,
    kargs = { name = LayoutName.AskAI },
  },
  {
    text = "layout: code and firefox",
    subText = cmdInfo.name.selectLayout,
    cmdName = cmdInfo.name.selectLayout,
    kargs = { name = LayoutName.CodeAndFirefox },
  },
  {
    text = "layout left: kitty, right: firefox",
    cmdName = cmdInfo.name.layoutLeftKittyRightFirefox,
  },
  {
    text = "preview image",
    subText = cmdInfo.name.preview,
    cmdName = cmdInfo.name.preview,
    image = imageFromPath("preview.icns"),
    kargs = {
      searchDirs = { "~/Downloads/", "~/Desktop/" },
      exts = { "jpeg", "png", "webp" }
    }
  },
  {
    text = "preview video",
    subText = cmdInfo.name.preview,
    cmdName = cmdInfo.name.preview,
    image = imageFromPath("preview.icns"),
    kargs = {
      exts = { "mov", "mp4" }
    }
  },
  {
    text = "split video n=1",
    subText = "將影片重新編碼, 並拆分成n份",
    cmdName = cmdInfo.name.splitVideo,
    kargs = {
      exts = { "mov", "mp4" },
      n = 1,
    }
  }
}

hs.window.animationDuration = 0

local function completionFn(choice)
  if not choice then return end
  if choice.cmdName then
    local cmdFunc = cmdInfo.cmdTable[choice.cmdName]
    if cmdFunc then
      cmdFunc(choice.kargs)
    end
    return
  end

  local win = hs.window.focusedWindow() -- Warn: 最小化的時候，此時win會沒有
  if win then
    if win:isFullScreen() then
      -- 全螢幕下如果沒退出，無法直接換到其它的視窗
      win:setFullscreen(false)
    end
  end
  if choice.bundleID then
    hs.application.open(choice.bundleID)
  else
    hs.application.launchOrFocus(choice.path)
  end

  -- 加在這裡不好，不一定都是想fullscreen, 有可能用到layout
  -- -- hs.window.focusedWindow():setFullscreen(false) -- 前面的視窗如果還是全螢幕，下一個視窗無法被切換過去
  -- -- hs.window.focusedWindow():sendToBack()
  -- -- hs.window.focusedWindow():setFullscreen(true)
  -- hs.timer.doAfter(0.4, function()
  --   -- 時間等一下，效果似乎會比較好，不然可能無法立即切成全螢幕
  --   -- Caution: 如果中途重載，或者發現都一直無法換成全螢幕（此時用按鍵用全螢幕也是異常），要將該app整個關閉，再次啟動會正常
  --   hs.window.focusedWindow():setFullscreen(true)
  -- end)
end


hs.hotkey.bind({ "cmd" }, ";", function()
  local chooser = hs.chooser.new(completionFn)
  chooser:choices(fuzzelList)
  chooser:show()
end)


-- 取得目前聚焦視窗並切換焦點
local function focus(direction)
  -- https://www.hammerspoon.org/docs/hs.window.html#focusWindowEast
  local win = hs.window.focusedWindow()
  if win then
    win["focusWindow" .. direction](win)
  end
end

-- ❌ 以下這種是錯的，不會改成視窗的位置和大小, 要靠setFrame來處理
-- local function move(direction)
--   local win = hs.window.focusedWindow()
--   if win then
--     win["moveOneScreen" .. direction](win)
--   end
-- end

local function move(direction)
  -- https://www.hammerspoon.org/docs/hs.window.html#setFrame

  local win = hs.window.focusedWindow()
  if win then
    local screens = hs.screen.allScreens()
    if #screens > 1 then
      -- 多螢幕：移動到相鄰螢幕 (未測試)
      win["moveOneScreen" .. direction]() -- 修正：不傳多餘參數
    else
      -- 單螢幕：模擬移動（推到畫面邊緣半屏）
      local f = win:frame()
      local screen = win:screen()
      local max = screen:fullFrame() -- 用 fullFrame 忽略 Dock/Menu bar
      local halfW, halfH = max.w / 2, max.h / 2

      if direction == "West" then -- 左半
        f.x = max.x
        f.y = max.y
        f.w = halfW
        f.h = max.h
      elseif direction == "East" then -- 右半
        f.x = max.x + halfW
        f.y = max.y
        f.w = halfW
        f.h = max.h
      elseif direction == "North" then -- 上半
        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = halfH
      elseif direction == "South" then -- 下半
        f.x = max.x
        f.y = max.y + halfH
        f.w = max.w
        f.h = halfH
      end
      win:setFrame(f, 0) -- 立即設定（無動畫）
    end
  end
end

hs.hotkey.bind({ "cmd" }, "left", function()
  focus("West")
end)
hs.hotkey.bind({ "cmd" }, "h", function()
  focus("West")
end)


hs.hotkey.bind({ "cmd" }, "right", function()
  focus("East")
end)
hs.hotkey.bind({ "cmd" }, "l", function()
  focus("East")
end)


hs.hotkey.bind({ "cmd" }, "up", function()
  focus("North")
end)
hs.hotkey.bind({ "cmd" }, "k", function()
  focus("North")
end)


hs.hotkey.bind({ "cmd" }, "down", function()
  focus("South")
end)
hs.hotkey.bind({ "cmd" }, "j", function()
  focus("South")
end)


--

-- https://www.hammerspoon.org/docs/hs.hotkey.html#assignable
hs.hotkey.bind({ "cmd", "shift" }, "left", function()
  move("West")
end)
hs.hotkey.bind({ "cmd", "shift" }, "h", function()
  move("West")
end)


hs.hotkey.bind({ "cmd", "shift" }, "right", function()
  move("East")
end)
hs.hotkey.bind({ "cmd", "shift" }, "l", function()
  move("East")
end)


hs.hotkey.bind({ "cmd", "shift" }, "up", function()
  move("North")
end)
hs.hotkey.bind({ "cmd", "shift" }, "k", function()
  move("North")
end)


hs.hotkey.bind({ "cmd", "shift" }, "down", function()
  move("South")
end)
hs.hotkey.bind({ "cmd", "shift" }, "j", function()
  move("South")
end)


-- 雖然系統預設的熱鍵就是如此，但是有的應用程式，例如: lmstudio 它也會有熱鍵，因此用hammerspoon可以覆寫
hs.hotkey.bind({ "cmd", "ctrl" }, "f", function()
  local win = hs.window.focusedWindow()
  if win:isFullScreen() then
    win:setFullscreen(false)
  else
    win:setFullscreen(true)
  end
end)
hs.hotkey.bind({ "cmd" }, "F1", function()
  spoon.Window.selectWindow()
end)


spoon.LeftRightHotkey:bind({ "lcmd" }, "f", function()
  -- 以下沒用
  -- local frontmostApp = hs.window.focusedWindow():application()
  -- if frontmostApp:name() == "Firefox" then
  --   hs.eventtap.keyStroke({ "cmd" }, "f", 0)
  -- end

  -- 如果在鍵盤只有一個cmd鍵，就只能放棄在firefox中用cmd+f來搜尋
  -- Tip: 但可以在非文字欄位中按下 / 如此可以啟動快速搜尋
  --  此時是否區分大小寫，仍然要在cmd+f設定才可以，可以用 Edit > Find 中也可以用UI的方式開啟cmd+f的視窗
  -- 👆 已經有綁定了一個 rCtrl, f  觸發原本的cmd+f 所以不需要用以上的操作也可以
  -- local win = hs.window.focusedWindow()
  -- win:maximize()

  -- Spoons/Toggle.spoon/init.lua
  spoon.Toggle.toggleMaximize()
end)


-- Spoons/LeftRightHotkey.spoon/init.lua
-- rAlt
spoon.LeftRightHotkey:bind({ "rCtrl" }, "f", -- Tip: 在mac上有很多應用程式，還是需要用cmd+f來搜尋，當將cmd+f設定為: `win:maximize()` 就要有其它代替搜尋的鍵，不然會很不方便
  nil,                                       -- Caution: 這種改鍵不要設定成pressedfn, 要寫在releasedfn來觸發
  function()
    -- hs.eventtap.event.newKeyEvent({ "cmd" }, "f", true):post()  -- 按壓
    -- hs.eventtap.event.newKeyEvent({ "cmd" }, "f", false):post() -- 彈起
    hs.eventtap.keyStroke({ "cmd" }, "f") -- 等同按壓＋彈起. 同等以上兩步驟
  end
)

hs.grid.setGrid('8x2')
-- Spoons/Layout.spoon/init.lua
spoon.Layout:add(LayoutName.Code, "1", {
  { 'kitty', '0,0 8x2' },
})

spoon.Layout:add(LayoutName.AskAI, nil, {
  { 'kitty',     '0,0 4x2' },
  -- { 'LM Studio', '4,0 4x2' }, -- 也可以考慮用成4x2，這樣聚焦時會自動展開
  { 'LM Studio', '4,0 4x1' },
  { 'Firefox',   '4,1 4x1' },
})

spoon.Layout:add(LayoutName.CodeAndFirefox, nil, {
  { 'kitty',   '0,0 4x2' },
  -- { 'Firefox', '4,0 4x2', false },
  { 'Firefox', '4,0 4x2' },
})
spoon.Layout:add(LayoutName.CodeAndPreview, "p", {
  { 'kitty',             '0,0 4x2' },
  { 'com.apple.Preview', '4,0 4x2' },
})

spoon.Layout:add(LayoutName.Firefox, "f", {
  { 'Firefox', '0,0 8x2' },
})

spoon.Layout:add(LayoutName.LmStudio, "a", { -- a as AI
  { 'ai.elementlabs.lmstudio', '0,0 8x2' },
})


hs.hotkey.bind({ "cmd" }, "1", spoon.Layout:get(LayoutName.Code).func)
hs.hotkey.bind({ "cmd" }, "2", spoon.Layout:get(LayoutName.Firefox).func)
hs.hotkey.bind({ "cmd" }, "3", spoon.Layout:get(LayoutName.LmStudio).func)


spoon.Layout:bind({ "cmd" }, "F2") -- cmd + F3 沒辦法用，可能被系統佔掉

-- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/alert.lua
hs.alert.show("config loaded")
