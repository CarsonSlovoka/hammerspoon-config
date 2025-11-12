hs = hs -- 減少未定義的警告
spoon = spoon

local hammerspoon_config_dir = os.getenv("HOME") .. '/.hammerspoon/'
package.path = package.path ..
    ';' .. hammerspoon_config_dir .. 'lua/?.lua'
-- hs.alert.show(package.path)
-- print(package.path)

-- local test = require("test")
local utils = require("utils.utils")
-- test.test()

hs.loadSpoon("Dock")
hs.loadSpoon("AClock")
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
    text = "google sheet",
    subText = cmdInfo.name.openBrowser,
    cmdName = cmdInfo.name.openBrowser,
    kargs = { url = "https://docs.google.com/spreadsheets" },
    image = imageFromPath("google-sheet.icns")
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
  },
  {
    text = "hammerspoon reload",
    -- cmd = function() hs.reload() end -- ❌ cannot be converted into a proper NSObject, 因此沒辦法直接用function, 只能額外用table去找對應要執行的函數
    cmdName = cmdInfo.name.hammerspoonReload,
  },
  {
    text = "list hs.image",
    cmdName = cmdInfo.name.listHsImage,
  },
  {
    text = "show clock",
    cmdName = cmdInfo.name.showClock,
  }
}

local function completionFn(choice)
  if not choice then return end
  if choice.cmdName then
    local cmdFunc = cmdInfo.cmdTable[choice.cmdName]
    if cmdFunc then
      cmdFunc(choice.kargs)
    end
    return
  end
  hs.application.launchOrFocus(choice.path)
end


hs.hotkey.bind({ "cmd" }, ";", function()
  local chooser = hs.chooser.new(completionFn)
  chooser:choices(fuzzelList)
  chooser:show()
end)

hs.alert.show("config loaded")
