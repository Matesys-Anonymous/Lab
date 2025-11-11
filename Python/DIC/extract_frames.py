import cv2
import os
from tqdm import tqdm

def extract_frames_from_video(video_path, duration_sec=10):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)  # DIC フォルダ
    result_root = os.path.join(base_dir, "Result")

    base_name = os.path.splitext(os.path.basename(video_path))[0]
    output_folder = os.path.join(result_root, base_name)

    print(f"[DEBUG] 動画ファイルパス: {video_path}")
    print(f"[DEBUG] 出力フォルダ: {output_folder}")

    # 動画存在チェック（先に！）
    if not os.path.exists(video_path):
        print(f"[エラー] 動画ファイルが存在しません：{video_path}")
        return

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"[エラー] 動画ファイルを開けませんでした：{video_path}")
        return

    # フォルダ作成（動画確認後に作成！）
    try:
        os.makedirs(output_folder, exist_ok=True)
    except Exception as e:
        print(f"[エラー] 出力先フォルダ作成失敗: {e}")
        cap.release()
        return

    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(fps * duration_sec)
    frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    total_frames = min(total_frames, frame_count)

    print(f"FPS: {fps:.2f}, フレーム数: {total_frames}")

    saved_count = 0
    for i in tqdm(range(total_frames)):
        ret, frame = cap.read()
        if not ret:
            print(f"[警告] フレーム取得失敗: {i}")
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        filename = os.path.join(output_folder, f"frame_{i:04d}.bmp")
        success = cv2.imwrite(filename, gray)
        if not success:
            print(f"[エラー] 書き込み失敗: {filename}")
        else:
            saved_count += 1

    cap.release()
    print(f"{saved_count} 枚のBMP画像を保存しました。")

# ======== 実行部 ========
if __name__ == "__main__":
    user_input = input("動画ファイル名またはフルパスを入力してください：").strip()
    if user_input.upper() == "MATESYSLAB":
        print("""
╔══════════════════════════════════╗
║研究がうまくいかなくても大丈夫です║
║      研究はそういうものです      ║
╚══════════════════════════════════╝
        (╯°□°）╯︵ ┻━┻
  今日も一日、ご機嫌で行きましょう☀️
""")
        input("▶ Enterキーを押して終了します...")
        exit()  # イースターエッグ発動後に終了するなら残す。処理続けたいなら削除。

    script_dir = os.path.dirname(os.path.abspath(__file__))
    movie_dir = os.path.join(os.path.dirname(script_dir), "Movie")

    if os.path.isfile(user_input):
        video_path = user_input
    else:
        video_path = os.path.join(movie_dir, user_input)

    duration_input = input("抽出秒数（例：10）：").strip()
    try:
        duration_sec = int(duration_input)
        if duration_sec <= 0:
            raise ValueError
    except:
        print("無効な値なので10秒で抽出します。")
        duration_sec = 10

    extract_frames_from_video(video_path, duration_sec)