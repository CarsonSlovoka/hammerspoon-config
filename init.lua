hs = hs -- 減少未定義的警告
spoon = spoon

local hammerspoon_config_dir = os.getenv("HOME") .. '/.hammerspoon/'
package.path = package.path ..
    ';' .. hammerspoon_config_dir .. 'lua/?.lua'
-- hs.alert.show(package.path)
-- print(package.path)

local test = require("test")
test.test()

hs.loadSpoon("Dock")
hs.loadSpoon("AClock")
-- 如此在它的終端機，可以直接使用
-- spoon.Dock.hideDock()

-- hs.hotkey.bind({ "alt" }, "R", function()
--   hs.reload()
-- end)

local fuzzelList = {
  { text = "Firefox", subText = "This is the subtext of the first choice", path = "/Applications/Firefox.app" },
  { text = "Kitty",   path = "/Applications/kitty.app" },
  { text = "Safari",  path = "/Applications/Safari.app" },
  {
    text = "google sheet",
    cmdName = "open browser",
    kargs = { url = "https://docs.google.com/spreadsheets" }
  },
  {
    text = hs.styledtext.new(
      "Possibility",
      {
        font = { size = 30 },
        color = hs.drawing.color.definedCollections.hammerspoon.green
      }
    ),
    subText = "What a lot of choosing there is going on here!",
    image = hs.image.imageFromName("NSComputer"),
  },

  {
    text = "hammerspoon reload",
    -- cmd = function() hs.reload() end -- ❌ cannot be converted into a proper NSObject, 因此沒辦法直接用function, 只能額外用table去找對應要執行的函數
    cmdName = "hammerspoon reload"
  },
  {
    text = "list hs.image",
    cmdName = "list hs.image"
  },
  {
    text = "show clock",
    cmdName = "show clock"
  }
}

local cmdTable = {
  ["hammerspoon reload"] = function()
    hs.reload()
  end,
  ["list hs.image"] = function()
    print(hs.image.systemImageNames)
    -- local searchIcon = hs.image.imageFromName("NSSearchFieldTemplate") -- 載入搜尋圖示
  end,
  ["show clock"] = function()
    spoon.AClock:toggleShow()
  end,
  ["open browser"] = function(kargs)
    -- local cmd = "firefox --window --new-tab " .. kargs.url -- ❌ 需要絕對路
    local cmd = "/opt/homebrew/bin/firefox --window --new-tab " .. kargs.url
    os.execute(cmd)
    -- hs.task.new("/bin/bash", nil, { "-c", cmd }):start()
    -- hs.osascript.applescript(string.format('do shell script "%s"', cmd))
  end
}

local function completionFn(choice)
  if not choice then return end
  if choice.cmdName then
    local cmdFunc = cmdTable[choice.cmdName]
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
