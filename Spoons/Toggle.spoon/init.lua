-- 記錄每個窗口的「未最大化前」位置
local orgFrames = {}

--- @deprecated 使用 hs.window:isMaximizable() 來取代
--- ~~判斷窗口是否已最大化（忽略 Dock / Menu bar~~ 👈 這可能不準
local function isMaximized(win)
  local frame  = win:frame()
  local screen = win:screen()
  local full   = screen:fullFrame() -- 只要螢幕區域，不含 Dock / Menu bar
  return frame.x == full.x and frame.y == full.y
      and frame.w == full.w and frame.h == full.h
end

--- 可以保留最大化前的視窗位置、大小. 若再次調用可以還原
local function toggleMaximize()
  local win = hs.window.focusedWindow()
  if not win then return end

  local key = win:id()
  local orig = orgFrames[key]

  -- 已最大化 → 還原
  if win:isMaximizable() and orig then
    -- 回到原始位置／大小，並且從表中移除
    win:setFrame(orig.frame)
    win:moveToScreen(orig.screen) -- 保持原螢幕
    orgFrames[key] = nil
  else
    -- 未最大化 → 記錄並最大化
    orgFrames[key] = {
      frame = win:frame(),
      screen = win:screen():id()
    }

    win:maximize()
  end
end

-- 綁定到左 Cmd + f（或你想要的組合）
-- spoon.LeftRightHotkey:bind({ "lcmd" }, "f", toggleMaximize)

return {
  toggleMaximize = toggleMaximize
}
