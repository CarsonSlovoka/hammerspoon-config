--- 此腳本解決Mac OS的鍵盤延遲設定不能很客製化的問題
---
--- 傳統只能這樣，但它不是完美
-- defaults write -g InitialKeyRepeat -float 8.0 # Initial delay       # mac 26可以低於10, 用3太快會沒辦法用, 建議不要低於6
-- defaults write -g KeyRepeat -int 1            # Key repeat interval # 最低只能1

local M = {}

local initialDelay = 0.03
local repeatRate = 0.01

local targetKeys = {
  -- left = true,
  -- right = true,
  -- up = true,
  -- down = true,
  -- delete = true,        -- Backspace（往左刪除）
  -- forwarddelete = true, -- Fn + Delete（往右刪除）
  h = true,
  j = true,
  k = true,
  l = true,
}

local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties

-- 用來識別自己產生的事件
local eventTag = 0x46525354

local timers = {}

local function stopTimers(keyCode)
  local state = timers[keyCode]
  if not state then return end

  timers[keyCode] = nil

  if state.delay then
    state.delay:stop()
  end

  if state.repeatTimer then
    state.repeatTimer:stop()
  end
end

-- 產生一次模擬連發
local function sendRepeat(keyCode)
  local event = hs.eventtap.event.newKeyEvent(keyCode, true)

  -- 讀取當前修飾鍵狀態
  event:setFlags(hs.eventtap.checkKeyboardModifiers())

  -- 標記成自己的事件
  event:setProperty(props.eventSourceUserData, eventTag)

  -- 標記成鍵盤自動連發
  event:setProperty(props.keyboardEventAutorepeat, 1)

  event:post()
end

function M.stop()
  if M.tap then
    M.tap:stop()
    M.tap = nil
  end

  for keyCode in pairs(timers) do
    stopTimers(keyCode)
  end
end

-- 查詢連發功能是否啟用
function M.isEnabled()
  return M.tap ~= nil and M.tap:isEnabled()
end

-- 切換連發功能
function M.toggle()
  if M.isEnabled() then
    M.stop()
    hs.alert.show("keyrepeat stop")
  else
    M.setup()
    hs.alert.show("keyrepeat on")
  end

  return M.isEnabled()
end

function M.enable(verbose)
  M.setup()
  if verbose then
    hs.alert.show("keyrepeat on")
  end
end

function M.disable(verbose)
  M.stop()
  if verbose then
    hs.alert.show("keyrepeat stop")
  end
end

function M.setup()
  -- 避免重複建立監聽器
  M.stop()

  M.tap = hs.eventtap.new({
    types.keyDown,
    types.keyUp,
  }, function(event)
    local keyCode = event:getKeyCode()

    -- 自己產生的事件直接放行，不參與計時器控制
    if event:getProperty(props.eventSourceUserData) == eventTag then
      return false
    end

    local keyName = hs.keycodes.map[keyCode]

    if not targetKeys[keyName] then
      return false
    end

    local eventType = event:getType()

    if eventType == types.keyDown then
      -- 阻擋 macOS 原生連發
      local isRepeat = event:getProperty(props.keyboardEventAutorepeat)

      if isRepeat and isRepeat ~= 0 then
        return true
      end

      -- 已經按住，不要重新建立計時器
      if timers[keyCode] then
        return true
      end

      local state = {}
      timers[keyCode] = state

      state.delay = hs.timer.doAfter(initialDelay, function()
        -- 防止延遲回呼在按鍵放開之後啟動
        if timers[keyCode] ~= state then
          return
        end

        local function emit()
          if timers[keyCode] ~= state then
            return
          end

          -- 避免監聽器停用或 Secure Input 開啟後持續送鍵
          if not M.tap
              or not M.tap:isEnabled()
              or hs.eventtap.isSecureInputEnabled()
          then
            stopTimers(keyCode)
            return
          end

          sendRepeat(keyCode)
        end

        -- 延遲結束，立即送出第一個連發
        emit()

        if timers[keyCode] == state then
          state.repeatTimer = hs.timer.doEvery(repeatRate, emit)
        end
      end)

      -- 放行實體按鍵的第一次 keyDown
      return false
    end

    if eventType == types.keyUp then
      stopTimers(keyCode)

      -- 放行實體按鍵的 keyUp
      return false
    end

    return false
  end)

  M.tap:start()
end

return M
