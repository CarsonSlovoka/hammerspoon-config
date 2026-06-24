local M = {
  -- Keep a history of focused windows
  windowHistory = {
    enable = false,
    items = {},
    size = 10
  },
}

local chooser = hs.chooser.new(function(choice)
  if not choice then
    return
  end
  choice.win:unminimize() -- 先解除最小化（如果有的話）
  choice.win:raise()      -- 提到最前面（很重要）
  choice.win:focus()      -- Important: 如果只有這個，當視窗已經隱藏的時候，會沒有辦法再打開
end)

local function imgFrom(name)
  -- https://github.com/CarsonSlovoka/hammerspoon-config/tree/3ebc93f/assets/img
  local path = os.getenv("HOME") .. '/.hammerspoon/assets/img/' .. name
  if hs.fs.displayName(path) then
    -- print(path)
    return hs.image.imageFromPath(path)
  end
  return nil
end

local function imageFromSystemApp(appName)
  return hs.image.imageFromPath(string.format("/System/Applications/%s/Contents/Resources/AppIcon.icns", appName)) or
      hs.image.imageFromPath(string.format("/System/Applications/%s/Contents/Resources/AppIconLoc.icns", appName)) -- 本地化的icns
end

local function imageFromApp(appName)
  return hs.image.imageFromPath(string.format("/Applications/%s/Contents/Resources/AppIcon.icns", appName)) or
      hs.image.imageFromPath(string.format("/Applications/%s/Contents/Resources/AppIconLoc.icns", appName))
end

---@param opt table?
function M.selectWindow(opt)
  opt = opt or {}
  local list = {}
  for _, win in ipairs(hs.window.allWindows()) do
    local app = win:application() -- 如果是`gitk --all` & 開出來的東西，得到的app會是nil
    local appName = app:name()

    -- bundleID 只對com.apple的項目取，這通常都是系統的工具，如果是第三方的之後的第三碼是一個id, 識別那個也不好
    -- 只抓是com.apple的bundleID, 並且不要前面的com.apple
    -- "^com%.apple%.(.+)" -- Warn: bundleID可能會多於三段，所以用 "^com%.apple%.([^%.]+)$" 才會取到最後一段
    -- 例如: com.apple.iWork.Numbers => Number
    local bundleIDLast = string.match(app and app:bundleID() or "", "^com%.apple%.([^%.]+)$") or ""
    local image
    if bundleIDLast == "" then
      image = imgFrom(string.gsub(appName, " ", "") .. ".icns")
    else
      local appN = bundleIDLast .. ".app"
      image = imageFromSystemApp(appN) or imageFromApp(appN)
    end

    table.insert(list, {
      win = win,
      text = win:title(),
      subText = appName .. " " .. bundleIDLast, -- 加上bundleID比較方便用英文搜尋
      -- subText = appName .. " " .. app:bundleID(),
      image = image
    })
  end

  chooser:searchSubText(opt.searchSubText or false) -- 使得subText可以被
  -- Note: 當SubText定義為應用程式的名稱時，會很有用
  chooser:choices(list)
  chooser:show()
end

-- Subscribe to window focus changes
function M:subscribeToWindowFocursed()
  if self.windowHistory.enable then
    return
  end

  hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(win, appName)
    if not win then
      return
    end

    -- 從頭插入, 從尾開始刪
    -- Insert the newly focused window at the front
    table.insert(M.windowHistory.items, 1, win)

    -- Keep our history list trimmed to a reasonable size
    if #M.windowHistory.items > M.windowHistory.size then
      -- Remove the last element
      table.remove(M.windowHistory.items)
    end
  end)

  self.windowHistory.enable = true
end

function M:getLastWindow()
  if not self.windowHistory.enable then
    hs.alert.show("Please run: `spoon.Window:subscribeToWindowFocursed()` first")
    return nil
  end

  if #self.windowHistory.items >= 2 then
    local lastWin = self.windowHistory.items[2]
    if lastWin and lastWin:isStandard() then
      -- lastWin:focus()
      -- hs.alert.show("get last window")
      return lastWin
    end
  else
    -- hs.alert.show("No previous window in history")
    return nil
  end
end

return M
