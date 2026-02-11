local M = {
  layouts = {
    {
      text = "📑 Main & Stack (7:3)",
      key = "1",
      value = {
        { x = 0,   y = 0,   w = 0.7, h = 1 },
        { x = 0.7, y = 0,   w = 0.3, h = 0.5 },
        { x = 0.7, y = 0.5, w = 0.3, h = 0.5 }
      },
    },
    {
      text = "🌓 Half halves (left and right)",
      key = "2",
      value = { hs.layout.left50, hs.layout.right50 }
    },
    {
      text = "🏛️ Three-column layout (1:1:1)",
      key = "3",
      value = {
        { x = 0, y = 0, w = 0.33, h = 1 }, { x = 0.33, y = 0, w = 0.34, h = 1 }, { x = 0.67, y = 0, w = 0.33, h = 1 }
      }
    },
    {
      text = "💠 Four squares (2x2)",
      key = "4",
      value = {
        { x = 0, y = 0,   w = 0.5, h = 0.5 }, { x = 0.5, y = 0, w = 0.5, h = 0.5 },
        { x = 0, y = 0.5, w = 0.5, h = 0.5 }, { x = 0.5, y = 0.5, w = 0.5, h = 0.5 }
      }
    },
    {
      text = "📏 Golden Ratio (L)",
      key = "l",
      value = { { x = 0, y = 0, w = 0.618, h = 1 }, { x = 0.618, y = 0, w = 0.382, h = 1 } }
    },
    {
      text = "🎯 Focus Mode",
      key = "f",
      value = { { x = 0.15, y = 0, w = 0.7, h = 1 } } -- 左右各留 15% 空白
    },
    {
      text = "🚥 Horizontal 3",
      key = "h",
      value = { { x = 0, y = 0, w = 1, h = 1 / 3 }, { x = 0, y = 1 / 3, w = 1, h = 1 / 3 }, { x = 0, y = 2 / 3, w = 1, h = 1 / 3 } }
    },
    {
      text  = "🌐 All Windows Grid",
      key   = "g",
      value = "grid_all" -- 特殊標記，函數中新增此流程的處理
    },
  }
}

function M.bind(mods, key)
  local function tileTwoWindows()
    local windows = hs.window.filter.new():getWindows() -- 獲取當前空間的所有視窗
    if #windows >= 2 then
      local win1 = windows[1]                           -- 當前或最近使用的
      local win2 = windows[2]                           -- 下一個最近使用的

      local screen = win1:screen():frame()

      -- 將 win1 設為左半部
      win1:setFrame({ x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h })
      -- 將 win2 設為右半部（聯動調整）
      win2:setFrame({ x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h })
    end
  end

  -- 通用的排列函數 (如此就不需要實作像 tileTwoWindows 的函數)
  local function applyLayout(layoutIndex)
    local layout = M.layouts[layoutIndex]
    if not layout then
      return
    end

    -- 獲取當前螢幕，避免在迴圈內重複呼叫
    local focusedScreen = hs.screen.mainScreen()

    -- 獲取當前空間的可見視窗排除隱藏視窗與桌面
    -- local windows = hs.window.filter.new():setAppFilter('Finder', { allowRoles = 'AXUnknown' }):getWindows()
    -- 使用 orderedWindows 取代 window.filter 這會根據 Z-order（最近使用）排序，且執行速度極快
    local windows = hs.window.orderedWindows()
    if layout.value == "grid_all" then
      local ws = {}
      for _, win in ipairs(windows) do
        if win:screen() == focusedScreen and win:isStandard() then
          table.insert(ws, win)
        end
      end
      local rect = hs.geometry(focusedScreen:frame()) -- 全螢幕範圍
      -- 或留一點邊距： rect = rect:scale(0.98, 0.98):translate(10, 10)

      -- 越小的 aspectRatio 越傾向橫向長條
      -- 1.0 ≈ 正方形傾向， 0.4 ≈ 偏寬扁平
      -- hs.window.tiling.tileWindows(windows, rect, 0.618) -- 黃金比例風格
      hs.window.tiling.tileWindows(ws, rect, 1.0) -- 將提供的windows盡可能的鋪滿整個畫面
      return
    end

    local frames = layout.value
    local count = 0

    -- 根據 layout 定義的數量來排列視窗
    for _, win in ipairs(windows) do
      -- 只處理目前螢幕上的標準視窗（排除 MenuBar, Dashboard 等）
      if win:screen() == focusedScreen and win:isStandard() then
        count = count + 1
        local frameRect = frames[count]

        if frameRect then
          win:move(frameRect, focusedScreen, true)
        end

        -- 填滿 layout 所需數量就停止
        if count >= #frames then
          break
        end
      end
    end
  end

  local mKey = hs.hotkey.modal.new(mods, key)
  function mKey:entered()
    local msg = ""
    for i, item in ipairs(M.layouts) do
      -- %-12s 左對齊
      -- %12s 右對齊
      msg = msg .. string.format("\n%-20s %s",
        item.key,
        item.text
      )
    end
    -- hs.alert.show(msg, nil, nil, 10)
    hs.alert.show(msg, 3)
    hs.timer.doAfter(3, function()
      -- 訊息消失時，也自動離開
      mKey:exit() -- 中途已經觸發exit再做一次也不會怎樣
    end)
  end

  local the_mods = {}
  local empty_msg = nil
  -- 動態綁定數字鍵 1, 2, 3...
  for i, l in ipairs(M.layouts) do
    -- local k = tostring(i)
    local k = l.key
    mKey:bind(the_mods, k,
      empty_msg,
      function()
        applyLayout(i)
        mKey:exit()
      end)
  end
end

-- M.bind({ "cmd" }, "d")

local function applyLayout(layoutRects)
  local allWindows = hs.window.filter.new():getWindows()
  local windowItems = {}

  for _, win in ipairs(allWindows) do
    table.insert(windowItems, {
      text = win:application():name(),
      subText = win:title(),
      id = win:id()
    })
  end

  local currentSlot = 1
  local selectedWindows = {}

  -- 遞迴選擇視窗，直到填滿佈局格子
  local function pickWindow()
    if currentSlot > #layoutRects then
      -- 開始執行移動
      for i, winId in ipairs(selectedWindows) do
        local w = hs.window.get(winId)
        if w then w:move(layoutRects[i]) end
      end
      return
    end

    local chooser = hs.chooser.new(function(choice)
      if choice then
        table.insert(selectedWindows, choice.id)
        currentSlot = currentSlot + 1
        pickWindow() -- 繼續選下一個格子的視窗
      end
    end)

    chooser:placeholderText("Choose the window to put in the " .. currentSlot .. " block...")
    chooser:choices(windowItems)
    chooser:show()
  end

  pickWindow()
end


function M.bindApplyLayout(mods, key)
  hs.hotkey.bind(mods, key,
    function()
      local layoutChooser = hs.chooser.new(
        function(choice)
          if choice then
            applyLayout(choice.value)
          end
        end
      )

      layoutChooser:placeholderText("Choose layout:")
      layoutChooser:choices(M.layouts)
      layoutChooser:show()
    end
  )
end

return M
