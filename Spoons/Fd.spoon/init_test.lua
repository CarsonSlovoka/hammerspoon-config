-- lua5.4 init_test.lua

package.path = package.path .. ';./?.lua'


local function Test_splitPath()
  local testPath                    =
  "~/Downloads/mpp_installer.app/Contents/Resources/AAAAAAAABBBBBBBBBBBBBBBBBB/em-US.lproj/InfoPlist.strings"
  local filename, dirText, fullpath = require("init").splitPath(testPath)
  print(filename, dirText, fullpath)
  if filename ~= "InfoPlist.strings" or
      dirText ~= "~/Downloads/mpp_inst…BBBBBBBB/em-US.lproj" or
      fullpath ~= testPath then
    return false
  end

  return true
end

for _, item in ipairs({
  { "Test_splitPath", Test_splitPath },
}) do
  local name = item[1]
  local func = item[2]
  if not func() then
    print("❌ " .. name)
  else
    print("✅ " .. name)
  end
end
