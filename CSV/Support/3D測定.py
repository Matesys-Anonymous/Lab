import pandas as pd
import pyperclip
import tkinter as tk
from tkinter import filedialog
import io


def ask_open_file(title, filetypes):
    root = tk.Tk()
    root.withdraw()
    root.lift()            # 最前面に持ってくる
    root.attributes('-topmost', True)
    file_path = filedialog.askopenfilename(title=title, filetypes=filetypes)
    root.destroy()
    return file_path


def ask_save_file(title, defaultextension, filetypes):
    root = tk.Tk()
    root.withdraw()
    root.lift()
    root.attributes('-topmost', True)
    file_path = filedialog.asksaveasfilename(
        title=title,
        defaultextension=defaultextension,
        filetypes=filetypes
    )
    root.destroy()
    return file_path


def txt_to_csv():
    txt_file = ask_open_file(
        title="変換するTXTファイルを選択してください",
        filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
    )
    if not txt_file:
        print("ファイルが選択されませんでした。")
        return

    csv_file = ask_save_file(
        title="保存するCSVファイル名を指定してください",
        defaultextension=".csv",
        filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
    )
    if not csv_file:
        print("保存先が選択されませんでした。")
        return

    df = pd.read_csv(txt_file, sep="\t", header=None)
    df.to_csv(csv_file, index=False, header=False)
    print(f"CSVに変換して保存しました: {csv_file}")


def clipboard_to_csv():
    text = pyperclip.paste()
    df = pd.read_csv(io.StringIO(text), sep="\t", header=None)

    csv_file = ask_save_file(
        title="保存するCSVファイル名を指定してください",
        defaultextension=".csv",
        filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
    )
    if not csv_file:
        print("保存先が選択されませんでした。")
        return

    df.to_csv(csv_file, index=False, header=False)
    print(f"クリップボードの内容をCSVに保存しました: {csv_file}")


if __name__ == "__main__":
    print("変換方法を選んでください：")
    print("1: TXTファイル → CSVへ変換")
    print("2: クリップボードの内容 → CSVへ変換")

    choice = input("番号を入力してください (1 or 2): ")

    if choice == "1":
        txt_to_csv()
    elif choice == "2":
        clipboard_to_csv()
    else:
        print("無効な選択です。")
