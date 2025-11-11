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
FFT_data_path = 'Testdata\解析データグラフ.xlsx';

% 読み込む変位データの列の設定
Displacement_row = 15; % xlsxなら1/csvなら3または4が一般的

% 単位変換用の設定
Unit_exchange = 1; % 0→設定の無視/1→μmに統一/2→mmに統一

% Displacement_rowとUnit_exchangeの干渉に注意して下さい。エラーの検知はできません。
% μmに統一したい(最大値が整数値くらい)→(DR,UE)=(3,0)/(4,1)・mmに統一したい(最大値が小数点以下になる)→(DR,UE)=(3,2)/(4,0)

% サンプリング周波数の打ち込み設定
Fs_setting_pram = 0; % ここの値を0にすれば自動計算モード・1にすれば直接入力モード

% サンプリング周波数というものが急にわからなくなってしまった人向け(自動計算モードに使う)
% データの個数を入力してください
Data_number = 2800;
% 全体の時間を入力してください。(解析→解析時間・実験→12)
Time = 0.01;

% サンプリング周波数をMATLABに計算してもらわなくても知っているとか、MATLABの計算能力を疑っている方向け
Fs_hand_setting = 60000; % ここに入力したならFs_setting_pramの変更を忘れずに

%% グラフ書式設定
% フォントの大きさが変わるよ
FONTSIZE = 16;
% フォントが変わるよ
FONTNAME = 'Times New Roman';

%% 設定の適用
Default_number = 1; % 緊急制御用のコード
Fs_auto_setting = Data_number/Time;

% パラメータ設定を簡単に書き換えられるようにする
if Fs_setting_pram == 0
    Fs_setting = Fs_auto_setting; % ←自動計算されます。(サンプリング周波数 [Hz])
elseif Fs_setting_pram == 1
    Fs_setting = Fs_hand_setting; % ←直接入力もできます。(サンプリング周波数 [Hz])
else
    fprintf('Fs_setting_pramの数値を確認してください。このコードは計算による制御で続行されます。\n');
    Fs_setting = Default_number; % ←おかしな結果が出ます。(サンプリング周波数 [Hz])
end

%% パラメータ設定
Fs = Fs_setting;  % サンプリング周波数 [Hz]
dt = 1 / Fs;

%% データ読み込み
data = readmatrix(FFT_data_path);
x = data(:,Displacement_row);  % A列の変位データ
% 単位変換
if Unit_exchange == 0
    x_exchange = x;
elseif Unit_exchange == 1
    x_exchange = x*(10^3);
elseif Unit_exchange == 2
    x_exchange = x*(10^(-3));
else
    fprintf('Unit_exchangeの数値を確認してください。このコードは単位変換は行われずに続行されます。\n');
    x_exchange = x; % 単位変換を行わずに続行
end

N = length(x);           % データ点数
t = (0:N-1) * dt;        % 時間ベクトル（参考用）

%% FFTの実行
Y = fft(x_exchange);               % 高速フーリエ変換
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