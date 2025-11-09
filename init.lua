hs = hs -- 減少未定義的警告

local hammerspoon_config_dir = os.getenv("HOME") .. '/.hammerspoon/'
package.path = package.path ..
    ';' .. hammerspoon_config_dir .. 'lua/?.lua'
-- hs.alert.show(package.path)
-- print(package.path)

local test = require("test")
test.test()

hs.loadSpoon("Dock")
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
  }
}

local cmdTable = {
  ["hammerspoon reload"] = function()
    hs.reload()
  end,
  ["list hs.image"] = function()
    print(hs.image.systemImageNames)
    -- local searchIcon = hs.image.imageFromName("NSSearchFieldTemplate") -- 載入搜尋圖示
  end
}

local function completionFn(choice)
  if not choice then return end
  if choice.cmdName then
    local cmdFunc = cmdTable[choice.cmdName]
    if cmdFunc then
      cmdFunc()
    end
    return
  end
  hs.application.launchOrFocus(choice.path)
end


hs.hotkey.bind({ "cmd" }, ";", function()
  -- hs.alert.show("cmd-:")
  local chooser = hs.chooser.new(completionFn)
  chooser:choices(fuzzelList)
  chooser:show()
end)

hs.alert.show("config loaded")
