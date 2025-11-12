[hammerspoon docs](https://www.hammerspoon.org/docs/)


## 目錄結構

`tree -L 4 -I "*.zip|*.html|*.js|*.sh|*.json|Makefile"`

```sh
.
├── Hammerspoon
│   └── Spoons  # 用submodule導入整個 https://github.com/Hammerspoon/Spoons.git 的專案, 方便同步
│       ├── docs
│       │   └── docs.css
│       ├── README.md
│       ├── Source  # 官方的插件
│       │   ├── AClock.spoon
│       │   ├── ...
│       │   └── ZeroOffset.spoon
│       └── Spoons
├── init.lua
├── LICENSE
├── lua
│   └── test.lua
├── README.md
└── Spoons  # 包含自定義與官方的插件, Tip: 如果是官方的插件，將使用ls的方式，用連結與 ./Hammerspoon/Spoons/Source/ 中的該插件目錄連結
    └── AClock.spoon
```

## icons

參考[assets/img/README.md](assets/img/README.md)

## [官方的plugin](https://github.com/Hammerspoon/Spoons)


```sh
# ~~git clone https://github.com/Hammerspoon/Spoons.git~~ 直接這樣clone, 目錄沒辦法對上

# 將官方的插件目錄，保存在 ~/.hammerspoon/Hammerspoon/Spoons/ 之中
mkdir -pv ~/.hammerspoon/Hammerspoon
git clone https://github.com/Hammerspoon/Spoons.git ~/.hammerspoon/Hammerspoon/Spoons/

# 讓 ~/.hammerspoon/Spoons 中的目錄與官方的目錄做連結
mkdir -pv ~/.hammerspoon/Spoons/
ln -siv ~/.hammerspoon/Hammerspoon/Spoons/Source/AClock.spoon ~/.hammerspoon/Spoons/AClock.spoon
```


### ~~各別導入~~

建議直接用submodule的方式
/Users/carson/github/go-set/.gitmodules

```sh
git clone https://github.com/Hammerspoon/Spoons.git ~/Spoons/
git log -1 # e5b87125  Date: 2025-05-12 (Mon) 22:59:11 +0000n
cp -r ~/Spoons/Source/AClock.spoon/ ./Spoons/AClock.spoon/
```
