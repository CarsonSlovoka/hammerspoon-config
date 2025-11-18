-- --- Usage:
-- M:chooser(function(selection)
--     hs.execute('open "' .. selection.fullpath .. '"')
--   end,
--   { "~/Downloads/", "~/Desktop/" },
--   "-e mp4 -e mov"
-- )


local M = {}

function M.splitPath(fullpath)
  -- 1️⃣取得檔名（basename）
  local filename = fullpath:match("^.+/(.+)$") or fullpath

  -- 2️⃣取得目錄路徑（dirname）
  local dir = fullpath:match("^(.+)/[^/]+$") or ""

  -- 3️⃣文字過長時，取前20 + … + 後20
  local subText
  if #dir > 80 then
    subText = dir:sub(1, 20) .. "…" .. dir:sub(-20)
  else
    subText = dir
  end

  return filename, subText, fullpath
end

---@param searchDirs table
---@param fdArgs string|? fd args for example: -e mov -e mp4
local function runFdSearch(searchDirs, fdArgs)
  local searchResults = {}
  for _, searchDir in ipairs(searchDirs) do
    -- fd . -e mov -e mp4 ~/Downloads
    local cmd = string.format("fd . %s %s",
      fdArgs or "",
      searchDir
    )
    print(cmd)

    -- hs.execute() 會同步執行指令，並回傳整個輸出字串
    -- local output = hs.execute(cmd) -- 如果是ls的這些命令，這樣可以
    -- hs.execute("which fd")
    local output = hs.execute(cmd, true) -- 如果要執行工具，需要載入環境變數

    -- 把每一行拆成單獨的路徑
    for line in output:gmatch("[^\r\n]+") do
      local filename, dirText, fullpath = M.splitPath(line)
      table.insert(searchResults, {
        text = filename,
        subText = dirText,
        fullpath = fullpath,
      })
    end
  end

  if #searchResults == 0 then
    print("❌ No files found")
  end
  return searchResults
end

--- 使用chooser來選擇想要的檔案, 可自定選擇後的動作
---@param completionFn function(selection)
---@param searchDirs table<string>
---@param fdArgs string? fd args for example: -e mov -e mp4
---@param opt table?
function M:chooser(completionFn, searchDirs, fdArgs, opt)
  opt = opt or {}
  local chooser = hs.chooser.new(completionFn)     -- 自定義處理的函數
  chooser:placeholderText(opt.placeholderText or "")
  chooser:choices(runFdSearch(searchDirs, fdArgs)) -- 執行fd取得相關的檔案路徑
  chooser:show()
  chooser:delete()
end

return M
