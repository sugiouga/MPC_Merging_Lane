% resultフォルダ内のすべてのCSVファイルをプロットするスクリプト
clear
close all

% 結果フォルダのパス
output_folder = 'result';

mainline_csv_files = dir(fullfile(output_folder, 'MainLine_Vehicle_*.csv'));
onramp_csv_files = dir(fullfile(output_folder, 'OnRamp_Vehicle_*.csv'));

% ファイル名からビークルIDを抽出してソート
mainline_vehicle_ids = arrayfun(@(x) str2double(extractBetween(x.name, 'MainLine_Vehicle_', '.csv')), mainline_csv_files);
[~, mainline_sorted_indices] = sort(mainline_vehicle_ids);
mainline_csv_files = mainline_csv_files(mainline_sorted_indices);

onramp_vehicle_ids = arrayfun(@(x) str2double(extractBetween(x.name, 'OnRamp_Vehicle_', '.csv')), onramp_csv_files);
[~, onramp_sorted_indices] = sort(onramp_vehicle_ids);
onramp_csv_files = onramp_csv_files(onramp_sorted_indices);

% 位置のプロット
figure(1);
hold on;
title('Position');
xlabel('Time [s]');
ylabel('Position [m]');
legend('show', 'Interpreter', 'none', 'Location', 'southeast'); % 右下に表示
ylim([0 500]); % Y軸の範囲を設定
grid on;

% 速度のプロット
figure(2);
hold on;
title('Velocity');
xlabel('Time [s]');
ylabel('Velocity [m/s]');
legend('show', 'Interpreter', 'none', 'Location', 'southeast'); % 右下に表示
ylim([0 35]); % Y軸の範囲を設定
grid on;

% 加速度のプロット
figure(3);
hold on;
title('Acceleration');
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
legend('show', 'Interpreter', 'none', 'Location', 'southeast'); % 右下に表示
ylim([-4 3]); % Y軸の範囲を設定
grid on;

% ジャークのプロット
figure(4);
hold on;
title('Jerk');
xlabel('Time [s]');
ylabel('Jerk [m/s^3]');
legend('show', 'Interpreter', 'none', 'Location', 'southeast'); % 右下に表示
ylim([-10 10]); % Y軸の範囲を設定
grid on;

% MainLineの車両をプロット
for i = 1:length(mainline_csv_files)
    % ファイル名を取得
    file_path = fullfile(output_folder, mainline_csv_files(i).name);

    % ビークルIDを抽出
    vehicle_id = extractBetween(mainline_csv_files(i).name, 'MainLine_Vehicle_', '.csv');

    % CSVファイルを読み込む
    data = readtable(file_path);

    % 時間、位置、速度、加速度、ジャークを取得
    Time = data.Time;
    Position = data.Position;
    Velocity = data.Velocity;
    Acceleration = data.Acceleration;
    Jerk = data.Jerk;

    line_style = ':'; % 点線
    line_color = [0.5, 0.5, 0.5]; % グレー
    marker = 'o'; % 補足としてマーカーを追加
    marker_size = 6; % マーカーサイズ
    marker_color = [0.5, 0.5, 0.5]; % マーカーの色をグレーに設定

    % 位置のプロット
    figure(1);
    plot(Time, Position, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['MainLine Vehicle ' char(vehicle_id)]);

    % 速度のプロット
    figure(2);
    plot(Time, Velocity, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['MainLine Vehicle ' char(vehicle_id)]);

    % 加速度のプロット
    figure(3);
    plot(Time, Acceleration, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['MainLine Vehicle ' char(vehicle_id)]);

    % ジャークのプロット
    figure(4);
    plot(Time, Jerk, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['MainLine Vehicle ' char(vehicle_id)]);
end

% OnRampの車両をプロット
for i = 1:length(onramp_csv_files)
    % ファイル名を取得
    file_path = fullfile(output_folder, onramp_csv_files(i).name);

    % ビークルIDを抽出
    vehicle_id = extractBetween(onramp_csv_files(i).name, 'OnRamp_Vehicle_', '.csv');

    % CSVファイルを読み込む
    data = readtable(file_path);

    % 時間、位置、速度、加速度、ジャークを取得
    Time = data.Time;
    Position = data.Position;
    Velocity = data.Velocity;
    Acceleration = data.Acceleration;
    Jerk = data.Jerk;

    line_style = '-'; % 実線
    line_color = 'b'; % 青色

    % 位置のプロット
    figure(1);
    plot(Time, Position, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['OnRamp Vehicle ' char(vehicle_id)]);

    % 速度のプロット
    figure(2);
    plot(Time, Velocity, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['OnRamp Vehicle ' char(vehicle_id)]);

    % 加速度のプロット
    figure(3);
    plot(Time, Acceleration, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['OnRamp Vehicle ' char(vehicle_id)]);

    % ジャークのプロット
    figure(4);
    plot(Time, Jerk, 'LineWidth', 2, 'LineStyle', line_style, 'Color', line_color, ...
        'DisplayName', ['OnRamp Vehicle ' char(vehicle_id)]);
end

% 各プロットをPNGファイルとして保存
saveas(figure(1), fullfile(output_folder, 'Position.png'));
saveas(figure(2), fullfile(output_folder, 'Velocity.png'));
saveas(figure(3), fullfile(output_folder, 'Acceleration.png'));
saveas(figure(4), fullfile(output_folder, 'Jerk.png'));

