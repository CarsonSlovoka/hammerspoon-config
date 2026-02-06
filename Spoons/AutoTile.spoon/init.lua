local M = {
  layouts = {
    {
      text = "Half halves (left and right)",
      value = { hs.layout.left50, hs.layout.right50 }
    },
    {
      text = "Three-column layout (1:1:1)",
      value = {
        { x = 0, y = 0, w = 0.33, h = 1 }, { x = 0.33, y = 0, w = 0.34, h = 1 }, { x = 0.67, y = 0, w = 0.33, h = 1 }
      }
    },
    {
      text = "Four squares (2x2)",
      value = {
        { x = 0, y = 0,   w = 0.5, h = 0.5 }, { x = 0.5, y = 0, w = 0.5, h = 0.5 },
        { x = 0, y = 0.5, w = 0.5, h = 0.5 }, { x = 0.5, y = 0.5, w = 0.5, h = 0.5 }
      }
    }
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

    -- 獲取當前空間的可見視窗排除隱藏視窗與桌面
    local windows = hs.window.filter.new():setAppFilter('Finder', { allowRoles = 'AXUnknown' }):getWindows()
    local frames = layout.value

    -- 根據 layout 定義的數量來排列視窗
    for i = 1, math.min(#windows, #frames) do
      local win = windows[i]
      local frameIndex = frames[i] -- hs.layout.left50

      win:move(frameIndex, nil, true)
    end
  end

  local mKey = hs.hotkey.modal.new(mods, key)
  function mKey:entered()
    local msg = ""
    for i, item in ipairs(M.layouts) do
      -- %-12s 左對齊
      -- %12s 右對齊
      msg = msg .. string.format("\n%-20d %s",
        i,
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
  for i, _ in ipairs(M.layouts) do
    local k = tostring(i)
    mKey:bind(the_mods, k,
      empty_msg,
      function()
        applyLayout(i)
        mKey:exit()
      end)
  end
end

-- M.bind({ "cmd" }, "z")

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
