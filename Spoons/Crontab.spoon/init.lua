-- Note: 可以考慮只用系統的方式: 例如: `*  9-18  *   *   *    osascript -e 'display notification "take a break\nNew Line\n123" with title "from crontab" sound name "Ping"'`

local M = {}

-- 模擬 crontab 的函數
-- 語法：cron("分 時 日 月 週", function() ... end)
-- 支援 * 和數字，週 (0-6, 0=星期日) 也支援
function M.cron(spec, fn)
  local minute, hour, day, month, dow = spec:match("^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)$")

  -- 轉換成 hs.timer.doAt 可接受的時間格式
  local function matchesCurrentTime()
    local now = os.date("*t")
    local function match(pattern, value)
      if pattern == "*" then return true end
      return tonumber(pattern) == value
    end

    return match(minute, now.min) and
        match(hour, now.hour) and
        match(day, now.day) and
        match(month, now.month) and
        match(dow, now.wday - 1) -- Lua wday: 1=星期日, cron: 0=星期日
  end

  hs.timer.doEvery(60, function(timer)
    if matchesCurrentTime() then
      fn()
    end
  end)
end

return M
