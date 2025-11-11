%% 注意事項 
% MATLAB R2024bで作成しました。
% 2024bより新しいMATLABで編集を行わないで下さい。やったら許しません。
% ペルソナ・ノン・グラータとして国外追放も辞さない考えです。
% 編集を阻害するものではありませんが2024bで開けなくなった瞬間にペルソナ・ノン・グラータに認定します。

%% 皆さん大好きおまじない
clear; clc; close all;

%% 設定(基本的にここだけいじればおーけー)
% FFTのデータのパスを簡単に書き換えられるようにする設定
% FFT_data_path = 'E:\Laboratory\実験データ\実験\生データ\2025-10-09\74.csv';
FFT_data_path = '52.csv';

%% グラフ書式設定
% フォントの大きさが変わるよ
FONTSIZE = 16;
% フォントが変わるよ
FONTNAME = 'Times New Roman';

%% プロンプト用のコード
% 読み込む変位データの列の設定の入力
prompt = "読み込む変位データの列は？\n";
x = input(prompt);
Displacement_row = x; % xlsxなら1/csvなら3または4が一般的

% サンプリング周波数の打ち込み設定の入力
prompt = "サンプリング周波数の打ち込み設定は？(0→自動/1→手動/2→実験モード(600000/12))\n";
x = input(prompt);
Fs_setting_pram = x;

if Fs_setting_pram == 0
    % データの個数の入力
    prompt = "データの個数は？(解析→いくつだろう？・実験→600000(0が5つ))\n";
    x = input(prompt);
    Data_number = x;
    % 時間の入力
    prompt = "全体の時間は？(解析→解析時間・実験→12)\n";
    x = input(prompt);
    Time = x;
    Fs_setting = Data_number/Time;
elseif Fs_setting_pram == 1
    prompt = "サンプリング周波数は？\n";
    x = input(prompt);
    Fs_hand_setting = x;
    Fs_setting = Fs_hand_setting;
elseif Fs_setting_pram == 2
    Data_number = 600000;
    Time = 12;
    Fs_setting = Data_number/Time;
else
    fprintf('「サンプリング周波数の打ち込み設定は？」に入力した数値を確認してください。このコードは停止されます。\n');
    return;
end

%% パラメータ設定
Fs = Fs_setting;  % サンプリング周波数 [Hz]
dt = 1 / Fs;

%% データ読み込み
data = readmatrix(FFT_data_path);
x = data(:,Displacement_row);  % A列の変位データ

N = length(x);           % データ点数
t = (0:N-1) * dt;        % 時間ベクトル（参考用）

%% FFTの実行
Y = fft(x);               % 高速フーリエ変換
P2 = abs(Y / N);          % 両側振幅スペクトル
P1 = P2(1:N/2+1);         % 片側振幅スペクトル
P1(2:end-1) = 2 * P1(2:end-1);

f = Fs * (0:(N/2)) / N;   % 周波数軸

%% オプション：ピーク検出
[peakVal, peakIdx] = max(P1);
fprintf('最大振幅周波数 = %.2f Hz（振幅 %.4f）\n', f(peakIdx), peakVal);

%% グラフの範囲を美しくするための設定
beautiful_graph = fix((f(peakIdx)/100)+1)*100;

%% 結果のプロット(全体)
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
grid on;

%% 結果のプロット(ピーク検出を元に(誤差あるかも))
% 最高のピーク値が最も右に来ていなければ誤差が出る。直す気になったまたは直せとの世論が高まったら直す。
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
xlim ([0, beautiful_graph]);
grid on;

%% 結果のプロット(ピーク検出を元に(誤差直ってるかも))
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
xlim ([0, beautiful_graph+100]);
grid on;

%% 結果のプロット(ピーク検出を元に(自動でダメなら最後は人力！))
% xlimの値をいじいじしてください。
% まとめてコメントアウトしてあります。「%{」と「%}」を削除して実行してください。
%{
figure;
plot(f, P1, 'LineWidth', 1.5);
set(gca,'FontSize',FONTSIZE,'FontName',FONTNAME);
xlabel('Frequency [Hz]');
ylabel('Amplitude');
title('FFT Amplitude Spectrum');
% xlim ([0, 300]);
grid on;
%}