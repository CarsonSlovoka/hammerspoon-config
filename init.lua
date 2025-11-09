hs = hs -- 減少未定義的警告

hs.loadSpoon("Dock")
-- 如此在它的終端機，可以直接使用
-- spoon.Dock.hideDock()

-- hs.hotkey.bind({ "alt" }, "R", function()
--   hs.reload()
-- end)

hs.alert.show("config loaded")
