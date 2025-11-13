--- 此插件希望做到像sway的效果: `bindsym $mod+r mode "resize"`

local M = {
  resize_step = 50
}

-- 辅助函数: 调整窗口 frame
local function resizeWindow(dx, dy)
  local win = hs.window.focusedWindow()
  if not win then return end -- 如果没有焦点窗口，忽略

  local f = win:frame()
  -- 調整寬、高
  f.w = f.w + dx
  f.h = f.h + dy
  win:setFrame(f)
end

---@class ResizeOption
---@field resize_step number?

---@param mods table  {"cmd"}
---@param key string "r"
---@param opt ResizeOption?
function M:setup(mods, key, opt)
  opt = opt or {}
  RESIZE_STEP = opt.resize_step or M.resize_step

  -- 觸發鍵
  -- local resizeMode = hs.hotkey.modal.new({ 'cmd' }, 'r')
  local resizeMode = hs.hotkey.modal.new(mods, key)

  -- 進入時提示
  function resizeMode:entered()
    hs.alert.show("Entered resize mode", 1.0) -- 显示 1 秒警报
  end

  -- 離開
  function resizeMode:exited()
    hs.alert.show("Exited resize mode", 1.0)
  end

  -- 绑定 Escape 键退出模式
  -- 在只會在綁定的key觸發後按下才會有效
  resizeMode:bind({}, 'escape', function()
    resizeMode:exit()
  end)

  -- 在模式中绑定 h/j/k/l 键进行 resize
  -- resizeMode:bind({}, 'key', 'description', function() end) -- 其中description會在觸發的時候顯示
  resizeMode:bind({}, 'h', 'Shrink width', function()
    resizeWindow(-RESIZE_STEP, 0)
  end)

  resizeMode:bind({}, 'j', 'Grow height', function()
    resizeWindow(0, RESIZE_STEP)
  end)

  resizeMode:bind({}, 'k', 'Shrink height', function()
    resizeWindow(0, -RESIZE_STEP)
  end)

  resizeMode:bind({}, 'l', 'Grow width', function()
    resizeWindow(RESIZE_STEP, 0)
  end)

  -- 可选: 绑定箭头键作为备选（如果不喜欢 hjkl）
  resizeMode:bind({}, 'left', 'Shrink width (arrow)', function()
    resizeWindow(-RESIZE_STEP, 0)
  end)

  resizeMode:bind({}, 'down', 'Grow height (arrow)', function()
    resizeWindow(0, RESIZE_STEP)
  end)

  resizeMode:bind({}, 'up', 'Shrink height (arrow)', function()
    resizeWindow(0, -RESIZE_STEP)
  end)

  resizeMode:bind({}, 'right', 'Grow width (arrow)', function()
    resizeWindow(RESIZE_STEP, 0)
  end)
end

return M
