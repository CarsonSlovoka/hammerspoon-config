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
}


local function completionFn(choice)
  if not choice then return end
  hs.application.launchOrFocus(choice.path)
end


hs.hotkey.bind({ "cmd" }, ";", function()
  -- hs.alert.show("cmd-:")
  local chooser = hs.chooser.new(completionFn)
  chooser:choices(fuzzelList)
  chooser:show()
end)

hs.alert.show("config loaded")
