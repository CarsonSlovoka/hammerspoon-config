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
--
local cfg = require("config")

-- https://www.hammerspoon.org/docs/hs.ipc.html#cliInstall
-- hs -c "hs.alert.show('Hello from nvim')"
-- Err: can't access Hammerspoon message port Hammerspoon; is it running with the ipc module loaded?
hs.ipc.cliInstall() -- 要安裝ipc才不會有以上錯誤 -- 當註解掉後，重新啟用, 再使用hs -c還是會遇到, 因此這不是一次性設定, 需寫在init.lua
-- ls -lh /opt/homebrew/bin/hs
-- /opt/homebrew/bin/hs -> /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
-- hs.ipc.cliInstall("/usr/local/bin") 做類似以下的事情
-- ln -s "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ipc/bin/hs" "/usr/local/bin/hs"
-- Tip: 跳轉到ipc.lua中找到cliInstall就會曉得它做的事情 /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/ipc.lua

-- 切換到指定 App 所在的 Space 並聚焦視窗
local function focusAppOnItsSpace(appName)
  local app = hs.application.get(appName)
  if not app then
    -- hs.alert.show(appName .. " 未開啟")
    return
  end

  local win = app:mainWindow()
  if not win then
    -- hs.alert.show(appName .. " 沒有可聚焦的視窗")
    return
  end

  local curSpace = hs.spaces.activeSpaceOnScreen()

  -- 找到視窗所在的 space ID
  local targetSpace = hs.spaces.windowSpaces(win)[1]
  if not targetSpace then
    hs.alert.show("找不到視窗的 space")
    return
  end

  -- 若已在同一個 Space，就不要再切換，避免多餘動畫
  if curSpace == targetSpace then
    win:focus()
    return
  else
    hs.spaces.gotoSpace(targetSpace)
    win:focus()
  end
end

-- hs.application.enableSpotlightForNameSearches(true)

for _, plugin in ipairs({
  "Dock",
  "AClock",
  "Crontab",
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
-- 這個其實不會比 hs.grid.show 要好用
  { "cmd", "shift" }, "r",
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
  Borwser = cfg.browser,
  LmStudio = "LmStudio",
}

-- fuzzelList 排序: 1(主termianl), 2(主瀏覽器), 3 (次terminal), 4(次瀏覽器), ...(之後的不客意排)
local fuzzelList = {
  {
    text = "Kitty",
    subText = "launchOrFocus",
    path = "/Applications/kitty.app",
    image = imageFromPath("kitty.icns"),
    order = cfg.termianl == "kitty" and 1 or 3,
  },
  {
    text = "ghostty",
    subText = "launchOrFocus",
    path = "/Applications/Ghostty.app",
    image = hs.image.imageFromPath("/Applications/Ghostty.app/Contents/Resources/Ghostty.icns"),
    order = cfg.termianl == "Ghostty" and 1 or 3,
  },
  {
    text = "Firefox",
    subText = "launchOrFocus",
    path = "/Applications/Firefox.app",
    image = imageFromPath("firefox.icns"),
    -- image = hs.image.imageFromPath(utils.image.getImage("firefox.svg")), -- ❌ 不能給svg
    order = cfg.browser == "Firefox" and 2 or 4,
  },
  {
    text = "Safari",
    subText = "launchOrFocus",
    path = "/Applications/Safari.app",
    image = imageFromPath("safari.icns"),
    order = cfg.browser == "Safari" and 2 or 4,
  },
  {
    text = "LmStudio",
    subText = "launchOrFocus",
    path = "/Applications/LM Studio.app",
    image = imageFromPath("lmstudio.icns")
  },
  {
    text = "ComfyUI",
    subText = "launchOrFocus",
    path = "/Applications/ComfyUI.app",
    -- image = hs.image.imageFromPath("/Applications/ComfyUI.app/Contents/Resources/UI/Comfy_Logo.icns")
    image = hs.image.imageFromPath("/Applications/ComfyUI.app/Contents/Resources/icon.icns")
  },
  {
    text = "teamviewer",
    subText = "launchOrFocus",
    path = "/Applications/TeamViewer.app/",
    image = utils.image.fromApp("TeamViewer.app"),
  },
  {
    text = "huggingface",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://huggingface.co/" },
    image = imageFromPath("huggingface.icns")
  },
  {
    text = "Calendar",
    subText = "launchOrFocus",
    path = "/System/Applications/Calendar.app",
    image = imageFromPath("calendar.icns")
  },
  {
    text = "free ruler", -- 尺規工具: https://apps.apple.com/tw/app/free-ruler/id1483172210?mt=12
    subText = "launchOrFocus",
    path = "/Applications/Free Ruler.app",
    image = utils.image.fromApp("Free Ruler.app"),
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
    image = utils.image.fromSystemApp("Freeform.app"),
  },
  {
    text = "numbers",
    subText = "launchOrFocus",
    path = "/Applications/Numbers.app",
    image = utils.image.fromApp("Numbers.app"),
  },
  {
    text = "pages",
    subText = "launchOrFocus",
    path = "/Applications/Pages.app",
    image = utils.image.fromApp("Pages.app"),
  },
  {
    text = "keynotes",
    subText = "launchOrFocus",
    path = "/Applications/Keynote.app",
    image = utils.image.fromApp("Keynote.app"),
  },
  {
    text = "stickies",
    subText = "launchOrFocus",                  -- 開啟之後 ⌘N 可以新增
    path = "/System/Applications/Stickies.app", -- ⌘⌥F 可以always on top
    image = utils.image.fromSystemApp("Stickies.app"),
  },
  {
    text = "textEdit",
    subText = "launchOrFocus",
    path = "/System/Applications/TextEdit.app",
    image = utils.image.fromSystemApp("TextEdit.app"),
  },
  {
    text = "facetime",
    subText = "launchOrFocus",
    path = "/System/Applications/Facetime.app",
    image = utils.image.fromSystemApp("Facetime.app"),
  },
  {
    text = "iphone mirroring",
    subText = "launchOrFocus",
    path = "/System/Applications/iPhone Mirroring.app/", -- 鏡像輸出
    image = utils.image.fromSystemApp("iPhone Mirroring.app"),
  },
  {
    text = "image playground", -- 需要開啟Apple Intelligence
    subText = "launchOrFocus",
    path = "/System/Applications/Image Playground.app",
    image = utils.image.fromSystemApp("Image Playground.app")
  },
  {
    text = "settings",
    subText = "launchOrFocus",
    path = "/System/Applications/System Settings.app",
    image = hs.image.imageFromPath(
      "/System/Applications/System Settings.app/Contents/Resources/SystemSettings.icns"
    ),
  },
  {
    text = "finder",
    subText = "launchOrFocus",
    path = "/System/Library/CoreServices/Finder.app",
    image = hs.image.imageFromPath(
      "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
    ),
    order = 10, -- 使得就算透過搜尋，也可以在find icon之前
  },
  {
    text = "show apps",
    subText = "launchOrFocus",
    path = "/System/Applications/Apps.app",
    -- Note: 如果將它從Dock中移除, 可以直接打開 `/System/Applications/` 找到該圖示後，直接將它拉到Dock上就可以再次出現在Dock上
    image = utils.image.fromSystemApp("Apps.app")
  },
  {
    text = "passwords",
    subText = "launchOrFocus",
    path = "/System/Applications/Passwords.app",
    image = utils.image.fromSystemApp("Passwords.app")
  },
  {
    text = "key chain access",
    subText = "launchOrFocus",
    path = "/System/Library/CoreServices/Applications/Keychain Access.app",
    image = hs.image.imageFromPath(
      "/System/Library/CoreServices/Applications/Keychain Access.app/Contents/Resources/AppIcon.icns"
    ),
  },
  {
    text = "phone",
    subText = "launchOrFocus",
    path = "/System/Applications/Phone.app",
    image = utils.image.fromSystemApp("Phone.app")
  },
  {
    text = "dictionary",
    subText = "launchOrFocus",
    path = "/System/Applications/Dictionary.app",
    image = utils.image.fromSystemApp("Dictionary.app")
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
    text = "g-calendar",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://calendar.google.com/calendar/" },
    image = imageFromPath("calendar.icns"),
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
    text = "gemini",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://gemini.google.com",
      windowName = { "Google Gemini" },
    },
    image = imageFromPath("gemini.icns"),
  },
  {
    text = "claude ai",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://claude.ai",
      windowName = { "Claude" },
    },
    image = imageFromPath("claude.icns"),
  },
  {
    text = "google ai studio",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = {
      url = "https://aistudio.google.com",
      windowName = { "Google AI Studio" },
    },
    image = imageFromPath("google-ai-studio.icns"),
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
    text = "stats",
    -- https://github.com/exelban/stats
    subText = "launchOrFocus",
    path = "/Applications/Stats.app",
    image = utils.image.fromApp("Stats.app"),
  },
  {
    text = "monitor (bashtop)",
    subText = "launchOrFocus",
    bundleID = "com.apple.ActivityMonitor",
    image = utils.image.fromSystemApp("Utilities/Activity Monitor.app")
  },
  {
    text = "user application",
    subText = cmdInfo.name.openDir,
    cmdName = cmdInfo.name.openDir,
    kargs = { path = "/Applications/" },
    image = imageFromPath("application-folder.icns"),
  },
  {
    text = "system application",
    subText = cmdInfo.name.openDir,
    cmdName = cmdInfo.name.openDir,
    kargs = { path = "/System/Applications/" },
    image = imageFromPath("application-folder.icns"),
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
  },
  {
    text = "toggle dock",
    subText = "Switch whether to automatically hide the Dock",
    cmdName = cmdInfo.name.toggleDock,
    image = imageFromPath("dock.icns")
  },
  {
    text = "shortcuts",
    subText = "launchOrFocus",
    path = "/System/Applications/Shortcuts.app",
    image = utils.image.fromSystemApp("Shortcuts.app")
  },
  {
    text = "photos",
    subText = "launchOrFocus",
    path = "/System/Applications/Photos.app",
    image = utils.image.fromSystemApp("Photos.app")
  },
  {
    text = "font book",
    subText = "launchOrFocus",
    path = "/System/Applications/Font Book.app",
    image = hs.image.imageFromPath("/System/Applications/Font Book.app/Contents/Resources/fontbook.icns"),
  },
  {
    text = "printer",
    subText = "launchOrFocus",
    path = "/System/Applications/Utilities/Print Center.app",
    image = utils.image.fromSystemApp("Utilities/Print Center.app")
  },
  {
    text = "flameshot",
    subText = "launchOrFocus",
    path = "/Applications/Flameshot.app",
    image = hs.image.imageFromPath("/Applications/Flameshot.app/Contents/Resources/flameshot.icns")
  },
  {
    text = "tips",
    subText = "launchOrFocus",
    path = "/System/Applications/Tips.app",
    image = utils.image.fromSystemApp("Tips.app")
  },
  {
    text = "image capture",
    subText = "Capture iPhone photos, image capture, scanner, etc.",
    path = "/System/Applications/Image Capture.app", -- 影像截取
    image = utils.image.fromSystemApp("Image Capture.app")
  },
  {
    text = "disk utility",
    subText = "format USB. disk splitting. disk information",
    path = "/System/Applications/Utilities/Disk Utility.app",
    image = utils.image.fromSystemUtilities("Disk Utility.app")
  },
  {
    text = "open trash",
    subText = cmdInfo.name.tellFinder,
    cmdName = cmdInfo.name.tellFinder,
    kargs = { cmd = "open trash" },
    -- kargs = { cmd = "empty trash" }, -- 清理，但是沒有尋問框
    image = utils.image.fromDockApp("trashfull.png")
    -- image = utils.image.fromDockApp("trashfull2@2x.png")
  },
  {
    text = "empty trash",
    subText = cmdInfo.name.runAppleScript,
    cmdName = cmdInfo.name.runAppleScript,
    kargs = {
      script = [[
      -- Warn: 讓對話框一定置頂 (因為是依附在hammerspoon, 所以是要激活hammerspoon)
      -- tell application "System Events" to activate
      tell application "Hammerspoon" to activate

      -- buttun的名稱使用buttons中的名稱
      -- dialog如果有需要換行，可以使用\n
      set theQuestion to display dialog "⚠️ Are you sure you want to permanently empty the trash?" ¬
          buttons {"Cancel", "🗑️ Empty Trash"} ¬
          default button "Cancel" ¬
          cancel button "Cancel" ¬
          with icon caution ¬
          with title "Empty Trash"

      if button returned of theQuestion is "🗑️ Empty Trash" then
          tell application "Finder"
              -- Warn: 如果垃圾筒已經是空的，是會回傳錯誤！
              empty trash
              -- display dialog "所有內容皆已清除!" -- dialog預設有"是, 否"所以用通知會比較好
          end tell

          -- 顯示通知 (會沒作用)
          -- display notification "my message" with title "My Notification" subtitle "for test" sound name "Frog"
      end if
    ]],
      ok_msg = os.date("%Y-%m-%d %H:%M:%S", os.time()) .. " Trash has been emptied",
      err_msg = "Cancel"
    },
    -- osascript -e 'display dialog "Hello world" with title "AppleScript Demo"'
    -- osascript -e 'display notification "my message" with title "My Notification" subtitle "for test" sound name "Frog"'
    image = utils.image.fromDockApp("trashempty.png")
  },
}

local last_item = {
  -- Tip: 將reload放在最後一個，如此一開始直接往上找就可以找到此項目
  text = "hammerspoon reload",
  -- cmd = function() hs.reload() end -- ❌ cannot be converted into a proper NSObject, 因此沒辦法直接用function, 只能額外用table去找對應要執行的函數
  cmdName = cmdInfo.name.hammerspoonReload,
  order = math.huge,
}

-- 🟧 加入所有 ~/Applications 中的app, 這些是shortcuts使用加入到Dock之後就會自動生成的項目
-- https://www.icloud.com/shortcuts/bed9c5f9ac064609bd688d691f4f32ae
local appFolder = os.getenv("HOME") .. "/Applications"
local iter, dir = require("hs.fs").dir(appFolder)
if iter then
  for file in iter, dir do
    if file:sub(1, 1) ~= "." then -- 跳過隱藏檔
      local fullPath = appFolder .. "/" .. file

      -- 只處理 .app 結尾的資料夾
      if file:match("%.app$") and require("hs.fs").attributes(fullPath, "mode") == "directory" then
        table.insert(fuzzelList, {
          text    = file:gsub("%.app$", ""), -- 去掉 .app 後綴
          subText = "launchOrFocus",
          path    = fullPath,
          image   = hs.image.imageFromPath(fullPath .. "/Contents/Resources/ShortcutIcon.icns"),
        })
      end
    end
  end
end

table.insert(fuzzelList, last_item)


-- Sort fuzzelList by order
table.sort(fuzzelList,
  function(a, b)
    local oa = a.order or math.huge
    local ob = b.order or math.huge
    return oa < ob -- ascending order; use > for descending
  end)

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

  local appNameOrBundleID = choice.bundleID or choice.path:match("([^/]+)%.app$")
  focusAppOnItsSpace(appNameOrBundleID)

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
hs.hotkey.bind({ "cmd" }, "r", function()
  -- 善用快截鍵
  hs.grid.show()
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
  spoon.Window.selectWindow({ searchSubText = true })
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


-- hs.grid.setGrid('10x5') -- 如果弄到第5列, 需要考慮f1, ..., f10 會按的有點不方便
hs.grid.setGrid('10x4') -- Tip: 鍵位其實就是鍵盤
-- Spoons/Layout.spoon/init.lua
spoon.Layout:add(LayoutName.Code, "1", {
  { cfg.termianl, '0,0 10x4' },
})

spoon.Layout:add(LayoutName.AskAI, nil, {
  { cfg.termianl, '0,0 5x4' },
  -- { 'LM Studio', '5,0 5x4' }, -- 也可以考慮用成5x4，這樣聚焦時會自動展開
  { 'LM Studio',  '5,0 5x1' },
  { cfg.browser,  '5,1 5x1' },
})

spoon.Layout:add(LayoutName.CodeAndFirefox, nil, {
  { cfg.termianl, '0,0 5x4' },
  -- { 'Firefox', '5,0 5x4', false },
  { cfg.browser,  '5,0 5x4' },
})
spoon.Layout:add(LayoutName.CodeAndPreview, "p", {
  { cfg.termianl,        '0,0 5x4' },
  { 'com.apple.Preview', '5,0 5x4' },
})

spoon.Layout:add(cfg.browser, "f", {
  { cfg.browser, '0,0 10x4' },
})

spoon.Layout:add(LayoutName.LmStudio, "a", { -- a as AI
  { 'ai.elementlabs.lmstudio', '0,0 10x4' },
})


hs.hotkey.bind({ "cmd" }, "1", spoon.Layout:get(LayoutName.Code).func)
hs.hotkey.bind({ "cmd" }, "2", spoon.Layout:get(LayoutName.Borwser).func)
hs.hotkey.bind({ "cmd" }, "3", spoon.Layout:get(LayoutName.LmStudio).func)


spoon.Layout:bind({ "cmd" }, "F2") -- cmd + F3 沒辦法用，可能被系統佔掉

-- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/alert.lua
hs.alert.show("config loaded")
