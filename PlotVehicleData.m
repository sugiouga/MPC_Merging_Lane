% resultフォルダ内のすべてのCSVファイルをプロットするスクリプト
clear
close all

% 結果フォルダのパス
output_folder = 'result';

% フォルダ内のすべてのCSVファイルを取得
csv_files = dir(fullfile(output_folder, 'vehicle_*.csv'));

% ファイル名からビークルIDを抽出してソート
vehicle_ids = arrayfun(@(x) str2double(extractBetween(x.name, 'vehicle_', '.csv')), csv_files);
[~, sorted_indices] = sort(vehicle_ids);
csv_files = csv_files(sorted_indices); % ソートされた順に並べ替え

% 位置のプロット
figure(1);
hold on;
title('Position');
xlabel('Time [s]');
ylabel('Position [m]');
grid on;

% 速度のプロット
figure(2);
hold on;
title('Velocity');
xlabel('Time [s]');
ylabel('Velocity [m/s]');
grid on;

% 加速度のプロット
figure(3);
hold on;
title('Acceleration');
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
grid on;

% 先行車両と後続車両の距離のプロット
figure(4);
hold on;
title('Distance from vehicle leading and following');
xlabel('Time [s]');
ylabel('Distance [m]');
grid on;

% ジャークのプロット
figure(5);
hold on;
title('Jerk');
xlabel('Time [s]');
ylabel('Jerk [m/s^3]');
grid on;

% 各CSVファイルを読み込んでプロット
for i = 1:length(csv_files)
    % ファイル名を取得
    file_path = fullfile(output_folder, csv_files(i).name);

    % CSVファイルを読み込む
    data = readtable(file_path);

    % 時間、位置、速度、加速度を取得
    Time = data.Time;
    Position = data.Position;
    Velocity = data.Velocity;
    Acceleration = data.Acceleration;
    Jerk = data.Jerk;

    % ビークルIDを取得
    vehicle_id = str2double(extractBetween(csv_files(i).name, 'vehicle_', '.csv'));

    % 位置のプロット
    figure(1);
    plot(Time, Position, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    ylim([0 1600]); % y軸の範囲を0から1600に設定
    legend show;

    % 速度のプロット
    figure(2);
    plot(Time, Velocity, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    ylim([15 35]); % y軸の範囲を15から30に設定
    legend show;

    % 加速度のプロット
    figure(3);
    plot(Time, Acceleration, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    ylim([-4 3]); % y軸の範囲を-3から2に設定
    legend show;

    % ジャークのプロット
    figure(5);
    plot(Time, Jerk, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    ylim([-5 5]); % y軸の範囲を-5から5に設定
    legend show;

    % 自車両を基準とした先行車両と後続車両の距離をプロット (ID >= 100 の場合)
    if vehicle_id >= 100
        % 先行車両と後続車両の距離を計算
        Lead_Vehicle_Distance = nan(height(data), 1);
        Follow_Vehicle_Distance = nan(height(data), 1);

        for j = 1:height(data)
            lead_vehicle_id = data.Lead_Vehicle_ID(j);
            follow_vehicle_id = data.Follow_Vehicle_ID(j);

            % 先行車両の距離を計算
            if ~isnan(lead_vehicle_id) && lead_vehicle_id > 0
                lead_vehicle_file = fullfile(output_folder, sprintf('vehicle_%d.csv', lead_vehicle_id));
                if isfile(lead_vehicle_file)
                    lead_vehicle_data = readtable(lead_vehicle_file);
                    Lead_Vehicle_Distance(j) = lead_vehicle_data.Position(j) - data.Position(j);
                end
            end

            % 後続車両の距離を計算
            if ~isnan(follow_vehicle_id) && follow_vehicle_id > 0
                follow_vehicle_file = fullfile(output_folder, sprintf('vehicle_%d.csv', follow_vehicle_id));
                if isfile(follow_vehicle_file)
                    follow_vehicle_data = readtable(follow_vehicle_file);
                    Follow_Vehicle_Distance(j) = data.Position(j) - follow_vehicle_data.Position(j);
                end
            end
        end

        % 距離のプロット
        figure(4);
        plot(Time, Lead_Vehicle_Distance, 'DisplayName', ['Leading (Vehicle ' num2str(lead_vehicle_id) ')'], 'LineWidth', 2);
        plot(Time, Follow_Vehicle_Distance, 'DisplayName', ['Following (Vehicle ' num2str(follow_vehicle_id) ')'], 'LineWidth', 2, 'LineStyle', '--');
        legend show;
    end

    saveas(figure(1), fullfile(output_folder, 'Position.png'));
    saveas(figure(2), fullfile(output_folder, 'Velocity.png'));
    saveas(figure(3), fullfile(output_folder, 'Acceleration.png'));
    saveas(figure(4), fullfile(output_folder, 'Distance.png'));
    saveas(figure(5), fullfile(output_folder, 'Jerk.png'));
end