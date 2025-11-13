-- Tip: 如以下路徑加入: /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ 即可偵測到相關的定義
--   https://github.com/CarsonSlovoka/nvim/commit/9c603a8074
-- hs = hs -- 減少未定義的警告
-- spoon = spoon

local hammerspoon_config_dir = os.getenv("HOME") .. '/.hammerspoon/'
package.path = package.path ..
    ';' .. hammerspoon_config_dir .. 'lua/?.lua'
-- hs.alert.show(package.path)
-- print(package.path)

-- local test = require("test")
local utils = require("utils.utils")
-- test.test()

for _, plugin in ipairs({
  "Dock",
  "AClock",
  "LeftRightHotkey",
  "Frame",
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
    text = "github",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://github.com/" },
    image = imageFromPath("github.icns")
  },
  {
    text = "discord",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://discord.com/channels/@me" },
    image = imageFromPath("discord.icns")
  },
  {
    text = "gmail",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://mail.google.com/mail" },
    image = imageFromPath("gmail.icns")
  },
  {
    text = "google sheet",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://docs.google.com/spreadsheets" },
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
    text = "list hs.image",
    cmdName = cmdInfo.name.listHsImage,
  },
  {
    text = "show clock",
    cmdName = cmdInfo.name.showClock,
  },
  {
    text = "layout left: kitty, right: firefox",
    cmdName = cmdInfo.name.layoutLeftKittyRightFirefox,
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

  local win = hs.window.focusedWindow()
  if win:isFullScreen() then
    -- 全螢幕下如果沒退出，無法直接換到其它的視窗
    win:setFullscreen(false)
  end
  hs.application.launchOrFocus(choice.path)

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


spoon.LeftRightHotkey:bind({ "lcmd" }, "f", function()
  -- 以下沒用
  -- local frontmostApp = hs.window.focusedWindow():application()
  -- if frontmostApp:name() == "Firefox" then
  --   hs.eventtap.keyStroke({ "cmd" }, "f", 0)
  -- end

  -- 如果在鍵盤只有一個cmd鍵，就只能放棄在firefox中用cmd+f來搜尋
  -- Tip: 但可以在非文字欄位中按下 / 如此可以啟動快速搜尋
  --  此時是否區分大小寫，仍然要在cmd+f設定才可以，可以用 Edit > Find 中也可以用UI的方式開啟cmd+f的視窗
  local win = hs.window.focusedWindow()
  win:maximize()
end)


hs.alert.show("config loaded")
