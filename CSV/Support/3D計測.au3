; クリップボードの内容をCSVとして保存するツール（UTF-8対応・保存前プレビューあり）

; クリップボードからデータ取得
$clip = ClipGet()
If $clip = "" Then
    MsgBox(16, "エラー", "クリップボードが空です。")
    Exit
EndIf

; プレビュー用に先頭2〜3行を抽出
Local $lines = StringSplit($clip, @CRLF, 1)
Local $preview = ""
Local $maxLines = 3
If $lines[0] < $maxLines Then $maxLines = $lines[0]
For $i = 1 To $maxLines
    $preview &= $lines[$i] & @CRLF
Next

; 確認メッセージボックス
Local $answer = MsgBox(4, "プレビュー確認", "以下の内容でCSVに保存します。よろしいですか？" & @CRLF & @CRLF & $preview)
If $answer = 7 Then
    MsgBox(48, "キャンセル", "保存をキャンセルしました。")
    Exit
EndIf

; 保存先を指定（ダイアログ）
$csv = FileSaveDialog("保存するCSVファイル名を指定してください", @ScriptDir, "CSV files (*.csv)", 2)
If @error Then
    MsgBox(48, "キャンセル", "保存がキャンセルされました。")
    Exit
EndIf

; UTF-8でファイルを開く（BOMは自動付与）
Local $fileOut = FileOpen($csv, 130) ; 128=UTF8 flag, +2=write mode
If $fileOut = -1 Then
    MsgBox(16, "エラー", "CSVファイルを開けません: " & $csv)
    Exit
EndIf

; 全行処理（タブをカンマに変換して保存）
For $i = 1 To $lines[0]
    $line = StringReplace($lines[$i], @TAB, ",")
    FileWriteLine($fileOut, $line)
Next

FileClose($fileOut)

MsgBox(64, "完了", "CSVに保存しました: " & $csv)
