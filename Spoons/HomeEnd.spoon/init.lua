local M = {}

-- 以下可行，但是監聽的成本很高, 與實際用option+up等方式，還是可以感受到微小的延遲
-- local homeEndKeyEvent = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
--   -- local flags = e:getFlags()
--   -- if flags.ctrl and flags.cmd then end
--
--   local code = e:getKeyCode()
--
--   -- /Applications/Hammerspoon.app/Contents/Resources/extensions/hs/keycodes.lua
--   local keyStr = hs.keycodes.map[code]
--   if keyStr ~= "home" and keyStr ~= "end" then
--     return false
--   end
--   local win = hs.window.focusedWindow()
--   if not win then
--     return false
--   end
--   if win:application():name() ~= "kitty" then
--     if keyStr == "home" or keyStr == "end" then
--     end
--     if keyStr == "home" then
--       hs.eventtap.keyStroke({ "option" }, "up")
--     else
--       hs.eventtap.keyStroke({ "option" }, "down")
--     end
--     -- return true -- 擋掉原本事件
--   end
--   return false
-- end)
-- homeEndKeyEvent:start()


-- 以下沒用，所有的Home都會套用, 沒辦法區分應用程式
-- hs.hotkey.bind({}, "Home", function()
--   if hs.window.focusedWindow():application():name() ~= "kitty" then
--     hs.eventtap.keyStroke({ "option" }, "up")
--   else
--     hs.eventtap.keyStroke({}, "Home") -- 這沒用
--   end
-- end)

hs.hotkey.bind({ "cmd" }, "Home", function()
  hs.eventtap.keyStroke({ "option" }, "up")
end)
hs.hotkey.bind({ "cmd", "shift" }, "Home", function()
  hs.eventtap.keyStroke({ "option", "shift" }, "up")
end)
hs.hotkey.bind({ "cmd" }, "End", function()
  hs.eventtap.keyStroke({ "option" }, "down")
end)
hs.hotkey.bind({ "cmd", "shift" }, "End", function()
  hs.eventtap.keyStroke({ "option", "shift" }, "down")
end)


return M
