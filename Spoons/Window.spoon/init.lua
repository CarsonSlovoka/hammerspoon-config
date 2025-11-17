local M = {}

function M.selectWindow()
  local list = {}
  for _, win in ipairs(hs.window.allWindows()) do
    table.insert(list, {
      win = win,
      text = win:title(),
      subText = win:application():name(),
    })
  end
  local chooser = hs.chooser.new(function(choice)
    if not choice then return end
    choice.win:focus()
  end)
  chooser:choices(list)
  chooser:show()
end

return M
