# LJ-S CSV 疑似カラー変換ツール

## ファイル
- `lj_s_pseudocolor.py`: 変換プログラム
- `LJ-S_CSVを疑似カラー化.bat`: CSVをドラッグ＆ドロップして実行するWindows用ファイル

## 準備
WindowsにPythonをインストールした後、コマンドプロンプトで次を1回実行してください。

    py -m pip install numpy matplotlib

## 最も簡単な使い方
1. 高さCSV（`_luminance`が付いていないCSV）をBATファイルへドラッグ＆ドロップします。
2. CSVと同じフォルダーに次の2画像が作成されます。
   - `元ファイル名_pseudocolor.png`: 画像のみ
   - `元ファイル名_pseudocolor_colorbar.png`: カラーバー付き

## 標準設定
- `-99.9999` は測定不能画素として黒く表示
- 有効高さ値の1パーセンタイルから99パーセンタイルを自動カラーレンジに使用
- カラーマップは `turbo`

## 複数測定を同じ色範囲で比較する
コマンドプロンプトから下限・上限を指定します。

    py lj_s_pseudocolor.py akazawa_hoge.csv --vmin 5.5 --vmax 11.5 --unit mm

## ファイル選択画面を使う

    py lj_s_pseudocolor.py

## 向きが異なる場合

    py lj_s_pseudocolor.py akazawa_hoge.csv --flip-x
    py lj_s_pseudocolor.py akazawa_hoge.csv --flip-y

## 注意
`*_luminance.csv` は輝度データです。形状の疑似カラー化には、通常、`_luminance`が付いていない高さCSVを使用します。
