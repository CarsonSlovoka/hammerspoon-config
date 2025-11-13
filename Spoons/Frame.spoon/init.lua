--- 此插件希望做到像sway的效果:
--- `bindsym $mod+r mode "resize"`
--- `bindsym $mod+Shift+Left move left`


local M = {
  resize_step = 50,
  move_step = 50,
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

-- 移動窗口 frame（新增）
local function moveWindow(dx, dy)
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.x = f.x + dx
  f.y = f.y + dy
  win:setFrame(f)
end

---@class ResizeOption
---@field resize_step number?
---@field move_step number?

---@param mods table  {"cmd"}
---@param key string "r"
---@param opt ResizeOption?
function M:setup(mods, key, opt)
  opt = opt or {}
  RESIZE_STEP = opt.resize_step or M.resize_step
  MOVE_STEP = opt.move_step or M.move_step

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

  --- 讓repeatfn等同pressedfn
  --- https://www.hammerspoon.org/docs/hs.hotkey.modal.html#bind
  local function bind(the_mods, the_key, message, pressedfn, releasedfn, repeatfn)
    resizeMode:bind(
      the_mods, the_key,
      message or nil, -- 如果為nil按鍵觸發不會有任何的提示, 如果非nil, 出現的提示前綴還會新增上觸發按鍵
      pressedfn,
      releasedfn or nil,
      repeatfn or pressedfn -- repeatfn
    )
  end

  -- 在模式中绑定 h/j/k/l 键进行 resize
  bind({}, 'h', '', function()
    resizeWindow(-RESIZE_STEP, 0)
  end)

  bind({}, 'j', 'Grow height', function()
    resizeWindow(0, RESIZE_STEP)
  end)

  bind({}, 'k', 'Shrink height', function()
    resizeWindow(0, -RESIZE_STEP)
  end)

  bind({}, 'l', 'Grow width', function()
    resizeWindow(RESIZE_STEP, 0)
  end)

  -- 可选: 绑定箭头键作为备选（如果不喜欢 hjkl）
  bind({}, 'left', 'Shrink width (arrow)', function()
    resizeWindow(-RESIZE_STEP, 0)
  end)

  bind({}, 'down', 'Grow height (arrow)', function()
    resizeWindow(0, RESIZE_STEP)
  end)

  bind({}, 'up', 'Shrink height (arrow)', function()
    resizeWindow(0, -RESIZE_STEP)
  end)

  bind({}, 'right', 'Grow width (arrow)', function()
    resizeWindow(RESIZE_STEP, 0)
  end)


  --- move ---
  local mod_move = { 'cmd', 'shift' }
  bind(mod_move, 'h', 'move left', function() moveWindow(-MOVE_STEP, 0) end)
  bind(mod_move, 'left', 'move left', function() moveWindow(-MOVE_STEP, 0) end)

  bind(mod_move, 'j', 'move down', function() moveWindow(0, MOVE_STEP) end)
  bind(mod_move, 'down', 'move down', function() moveWindow(0, MOVE_STEP) end)

  bind(mod_move, 'k', 'move up', function() moveWindow(0, -MOVE_STEP) end)
  bind(mod_move, 'up', 'move up', function() moveWindow(0, -MOVE_STEP) end)

  bind(mod_move, 'l', 'move right', function() moveWindow(MOVE_STEP, 0) end)
  bind(mod_move, 'right', 'move right', function() moveWindow(MOVE_STEP, 0) end)
end

return M
