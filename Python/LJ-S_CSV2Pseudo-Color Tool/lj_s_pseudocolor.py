#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""LJ-S Navigator height CSV -> pseudocolor PNG converter.

Usage:
  python lj_s_pseudocolor.py measurement.csv
  python lj_s_pseudocolor.py measurement.csv --vmin 5.5 --vmax 11.5
  python lj_s_pseudocolor.py measurement.csv --cmap viridis --invalid-color transparent

If no CSV is specified, a file selection dialog opens.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

INVALID_HEIGHT = -99.9999


def select_csv() -> Path | None:
    try:
        import tkinter as tk
        from tkinter import filedialog
        root = tk.Tk()
        root.withdraw()
        name = filedialog.askopenfilename(
            title="LJ-Sの高さCSVを選択",
            filetypes=[("CSV files", "*.csv"), ("All files", "*.*")],
        )
        root.destroy()
        return Path(name) if name else None
    except Exception as exc:
        print(f"ファイル選択画面を開けませんでした: {exc}", file=sys.stderr)
        return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="LJ-S Navigatorの高さCSVを疑似カラーPNGへ変換します。"
    )
    parser.add_argument("csv", nargs="?", help="高さCSV。省略時は選択画面を表示")
    parser.add_argument("--vmin", type=float, help="カラーレンジ下限。省略時は有効値の1%%点")
    parser.add_argument("--vmax", type=float, help="カラーレンジ上限。省略時は有効値の99%%点")
    parser.add_argument("--cmap", default="turbo", help="Matplotlibカラーマップ（既定: turbo）")
    parser.add_argument(
        "--invalid-color", default="black",
        help="無効画素の色（black, white, transparentなど。既定: black）",
    )
    parser.add_argument("--dpi", type=int, default=220, help="カラーバー付き画像のDPI（既定: 220）")
    parser.add_argument("--unit", default="Height value", help="カラーバーの単位・ラベル")
    parser.add_argument("--flip-x", action="store_true", help="左右反転")
    parser.add_argument("--flip-y", action="store_true", help="上下反転")
    return parser.parse_args()


def load_height_csv(path: Path) -> np.ndarray:
    print(f"読み込み中: {path}")
    try:
        data = np.loadtxt(path, delimiter=",", dtype=np.float32)
    except ValueError as exc:
        raise ValueError(
            "CSVを数値行列として読めませんでした。高さCSVを指定しているか確認してください。"
        ) from exc
    if data.ndim != 2:
        raise ValueError("CSVが2次元の数値行列ではありません。")
    return data


def main() -> int:
    args = parse_args()
    csv_path = Path(args.csv).expanduser() if args.csv else select_csv()
    if not csv_path:
        print("キャンセルしました。")
        return 0
    csv_path = csv_path.resolve()
    if not csv_path.exists():
        print(f"ファイルが見つかりません: {csv_path}", file=sys.stderr)
        return 1
    if csv_path.name.lower().endswith("_luminance.csv"):
        print("警告: _luminance.csv は輝度データです。通常は名前に _luminance がない高さCSVを選びます。")

    try:
        height = load_height_csv(csv_path)
        invalid = np.isclose(height, INVALID_HEIGHT, rtol=0.0, atol=5e-5) | ~np.isfinite(height)
        valid = height[~invalid]
        if valid.size == 0:
            raise ValueError("有効な高さ値がありません。")

        vmin = float(args.vmin) if args.vmin is not None else float(np.percentile(valid, 1.0))
        vmax = float(args.vmax) if args.vmax is not None else float(np.percentile(valid, 99.0))
        if not vmin < vmax:
            raise ValueError(f"カラーレンジが不正です: vmin={vmin}, vmax={vmax}")

        if args.flip_x:
            height = np.fliplr(height)
            invalid = np.fliplr(invalid)
        if args.flip_y:
            height = np.flipud(height)
            invalid = np.flipud(invalid)

        masked = np.ma.masked_where(invalid, height)
        cmap = plt.get_cmap(args.cmap).copy()
        cmap.set_bad((0, 0, 0, 0) if args.invalid_color.lower() == "transparent" else args.invalid_color)

        stem = csv_path.stem
        plain_path = csv_path.with_name(f"{stem}_pseudocolor.png")
        bar_path = csv_path.with_name(f"{stem}_pseudocolor_colorbar.png")

        # Pixel-perfect pseudocolor image without axes/colorbar.
        plt.imsave(plain_path, masked, cmap=cmap, vmin=vmin, vmax=vmax, origin="upper")

        # Presentation image with axes and colorbar.
        fig, ax = plt.subplots(figsize=(10, 8))
        image = ax.imshow(
            masked, cmap=cmap, vmin=vmin, vmax=vmax,
            origin="upper", interpolation="nearest", aspect="equal"
        )
        ax.set_title(f"LJ-S height map: {csv_path.name}")
        ax.set_xlabel("X pixel")
        ax.set_ylabel("Y pixel")
        colorbar = fig.colorbar(image, ax=ax)
        colorbar.set_label(args.unit)
        fig.tight_layout()
        fig.savefig(bar_path, dpi=args.dpi, bbox_inches="tight")
        plt.close(fig)

        print("変換完了")
        print(f"  配列サイズ       : {height.shape[1]} x {height.shape[0]}")
        print(f"  有効高さ範囲     : {float(valid.min()):.6g} ～ {float(valid.max()):.6g}")
        print(f"  表示カラーレンジ : {vmin:.6g} ～ {vmax:.6g}")
        print(f"  無効画素数       : {int(invalid.sum())}")
        print(f"  画像のみ         : {plain_path}")
        print(f"  カラーバー付き   : {bar_path}")
        return 0
    except Exception as exc:
        print(f"エラー: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
