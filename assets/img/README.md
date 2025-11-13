# 圖標取得

## [macosicons.com](https://macosicons.com)

- [Firefox__Liquid_Glass_.icns](https://macosicons.com/#/?icon=uQ840QiA7p)
- [_Numbers__Dark_.icns](https://macosicons.com/#/?icon=DQxCTfUmPP)
- [Safari](https://macosicons.com/#/?icon=nWnpPG0KU9)
- [lmstudio](https://macosicons.com/#/?icon=LygJuzb0fj)
- [calendar](https://macosicons.com/#/?icon=aB61H9yTMc)
- [google-sheet](https://macosicons.com/#/?icon=65Z2u8izcQ)
- [google-translate](https://macosicons.com/#/?icon=edTOLBtgP1)
- [calculator](https://macosicons.com/#/?icon=JdrgercRpq)
- [download-folder](https://macosicons.com/#/?icon=rfI5pVAFTB)
- [discord](https://macosicons.com/#/?icon=ExKVJjQHK6)

> [!NOTE]
> 這邊載的圖片，通常都還會有背景


```sh
mv-here() {
  output=$1
  input=$(ls -t1 ~/Downloads/*.icns | head -n 1)
  # mv -v ~/Downloads/*.icns .
  # icnsKeep $(ls -t1 *.icns | head -n 1) $output "32@2x"
  icnsKeep $input $output.icns "32@2x"
  rm -v $input
  open -a Preview $output.icns
}
# mv-here gmail
```


## [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)

- [firefox.svg](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/blob/master/Papirus/64x64/apps/firefox.svg)

```sh
wget https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/721c5a9/Papirus/64x64/apps/firefox.svg
wget https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/721c5a9/Papirus/64x64/apps/kitty.svg
```

# icns 相關腳本參考

```sh
_svg2icns my.svg
# svg2icns --retina my.svg 16 32
# svg2icns my.svg 32  # 不需要用retina的版本, 製成上如果用retina的版本, 16x16@2x 會比純32x32的還要大很多, 但是這樣看起來真得比較差
svg2icns -r --no-normal my.svg 32 # 這可以做到64x64, 一般的不能直接放64, 因為呎吋只有16/32/128/256/512 用64正常的iconutil會沒辦法生成，只能依靠retina

# 只要部份的png
icnsKeep input.icns output.icns "32.png"  # 用這個就差不多了
icnsKeep lmstudio.icns lmstudio.icns "32@2x" # 有的檔案只有做retina

# 查看原icns的資料
iconutil -c iconset source.icns -o temp.iconset
```

## svg2icns

```sh
# .zshrc
# `svg2icns firefox.svg`
svg2icns() {
    SVG=$1
    ICNS="${SVG%.*}.icns"
    ICONSET="${ICNS%.*}.iconset"  # Warn: 輸出的目錄名稱結尾必須是.iconset結尾
    ICONSET="$(mktemp -d)/$ICONSET"
    mkdir -p "$ICONSET"

    # SIZES=(16 32 128 256 512)
    # for size in "${SIZES[@]}"; do
    #     # 標準
    #     magick -background none -density 1000 "$SVG" -resize "${size}x${size}!" "$ICONSET/icon_${size}x${size}.png"
    #
    #     # @2x for Retina
    #     magick -background none -density 1000 "$SVG" -resize "$((size*2))x$((size*2))!" "$ICONSET/icon_${size}x${size}@2x.png"
    # done

    #  剩下的如果沒有, mac會自己用這些去生成, 建議給大的圖, 512會比較好，但是為了使最終的檔案比較小，就用32x32的版本, 而且一張足矣
    magick -background none -density 1000 "$SVG" -resize '32x32!' "$ICONSET/icon_32x32.png"
    # magick -background none -density 1000 "$SVG" -resize '32x32!' "$ICONSET/icon_32x32@2x.png"

    iconutil -c icns "$ICONSET" -o "$ICNS"
    rm -rf "$ICONSET"
    echo "✅ Generated: $ICNS"
}
```

## icnsKeep


```sh
# .zshrc

# `icnsKeep firefox.icns firefox_kept.icns "32|32@2x|128@2x"`
# `icnsKeep firefox.icns firefox_kept.icns "32.png"`
icnsKeep() {
  icns_file=$1
  outfile=$2
  pattern=$3

  iconset_dir="$(mktemp -d)/tmp.iconset"
  iconutil -c iconset "$icns_file" -o $iconset_dir  # 輸出的資料夾名稱結尾必需是iconset

  echo "🟧 iconset 原檔案解出來的內容"
  ls -lh $iconset_dir

  echo "🟧 被移除的圖片"
  rm -v $(find $iconset_dir -type f ! -regex "*.png" | grep -Ev "$pattern")
  iconutil -c icns "$iconset_dir" -o $outfile

  echo "🟧 最後製成的source圖片"
  ls -lh $iconset_dir

  echo "🟧 清理暫存目錄"
  rm -rfv $iconset_dir
}
```

