--- DEPRECATED 這是一個實驗的腳本，想用按鍵持續按下之後再慢慢調整: initialDelay 的速度，但用起來感覺還是不好

local M = {}

-- 基本設定
local initialDelay = 0.06
local repeatRate = 0.001

-- 加速設定
local minDelay = 0.01
local accelerationStep = 0.4

assert(repeatRate > 0)
assert(initialDelay >= minDelay)
assert(minDelay >= repeatRate)
assert(accelerationStep > 0)

local targetKeys = {
  left = true,
  right = true,
  up = true,
  down = true,
  delete = true,        -- Backspace（往左刪除）
  forwarddelete = true, -- Fn + Delete（往右刪除）
  h = true,
  j = true,
  k = true,
  l = true,
}

local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties

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

local function sendRepeat(keyCode)
  local event = hs.eventtap.event.newKeyEvent(keyCode, true)

  event:setFlags(hs.eventtap.checkKeyboardModifiers())
  event:setProperty(props.eventSourceUserData, eventTag)
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

function M.isEnabled()
  return M.tap ~= nil and M.tap:isEnabled()
end

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

function M.setup()
  M.stop()

  M.tap = hs.eventtap.new({
    types.keyDown,
    types.keyUp,
  }, function(event)
    local keyCode = event:getKeyCode()

    -- 忽略自己產生的按鍵事件
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

      if timers[keyCode] then
        return true
      end

      -- 每次按下都從初始速度開始
      local state = {
        currentDelay = initialDelay,
        nextRepeatAt = nil,
      }

      timers[keyCode] = state

      state.delay = hs.timer.doAfter(initialDelay, function()
        if timers[keyCode] ~= state then
          return
        end

        local function emit()
          if timers[keyCode] ~= state then
            return
          end

          if not M.tap
              or not M.tap:isEnabled()
              or hs.eventtap.isSecureInputEnabled()
          then
            stopTimers(keyCode)
            return
          end

          -- 單調遞增時間，單位轉為秒
          local now = hs.timer.absoluteTime() / 1e9

          -- 尚未到達下一次連發時間
          if state.nextRepeatAt
              and now < state.nextRepeatAt
          then
            return
          end

          -- 送出一次連發
          sendRepeat(keyCode)

          -- 設定下一次連發時間
          state.nextRepeatAt = now + state.currentDelay

          -- 逐漸加速，但不小於 minDelay
          state.currentDelay = math.max(
            minDelay,
            state.currentDelay - accelerationStep
          )
        end

        -- 第一次連發立即執行
        emit()

        -- 固定每 repeatRate 秒檢查一次
        if timers[keyCode] == state then
          state.repeatTimer = hs.timer.doEvery(repeatRate, emit)
        end
      end)

      return false
    end

    if eventType == types.keyUp then
      -- 放開按鍵，停止連發並重置加速狀態
      stopTimers(keyCode)
      return false
    end

    return false
  end)

  M.tap:start()
end

return M
