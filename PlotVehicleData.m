% resultフォルダ内のすべてのCSVファイルをプロットするスクリプト

% 結果フォルダのパス
output_folder = 'result';

% フォルダ内のすべてのCSVファイルを取得
csv_files = dir(fullfile(output_folder, 'vehicle_*.csv'));

% ファイル名からビークルIDを抽出してソート
vehicle_ids = arrayfun(@(x) str2double(extractBetween(x.name, 'vehicle_', '.csv')), csv_files);
[~, sorted_indices] = sort(vehicle_ids);
csv_files = csv_files(sorted_indices); % ソートされた順に並べ替え

% 位置のプロット
figure;
hold on;
title('Position vs Time');
xlabel('Time [s]');
ylabel('Position [m]');
grid on;

% 速度のプロット
figure;
hold on;
title('Velocity vs Time');
xlabel('Time [s]');
ylabel('Velocity [m/s]');
grid on;

% 加速度のプロット
figure;
hold on;
title('Acceleration vs Time');
xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
grid on;

% 先行車両と後続車両の距離のプロット
figure;
hold on;
title('Lead and Follow Distance vs Time');
xlabel('Time [s]');
ylabel('Distance [m]');
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

    % ビークルIDを取得
    vehicle_id = str2double(extractBetween(csv_files(i).name, 'vehicle_', '.csv'));

    % 位置のプロット
    figure(1);
    plot(Time, Position, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    legend show;

    % 速度のプロット
    figure(2);
    plot(Time, Velocity, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    legend show;

    % 加速度のプロット
    figure(3);
    plot(Time, Acceleration, 'DisplayName', ['Vehicle ' num2str(vehicle_id)], 'LineWidth', 2);
    legend show;

    % 自車両を基準とした先行車両と後続車両の距離をプロット (ID >= 100 の場合)
    if vehicle_id >= 100
        % 先行車両と後続車両の距離を計算
        LeadDistance = nan(height(data), 1);
        FollowDistance = nan(height(data), 1);

        for j = 1:height(data)
            lead_vehicle_id = data.Lead_Vehicle_ID(j);
            follow_vehicle_id = data.Follow_Vehicle_ID(j);

            % 先行車両の距離を計算
            if ~isnan(lead_vehicle_id) && lead_vehicle_id > 0
                lead_vehicle_file = fullfile(output_folder, sprintf('vehicle_%d.csv', lead_vehicle_id));
                if isfile(lead_vehicle_file)
                    lead_vehicle_data = readtable(lead_vehicle_file);
                    LeadDistance(j) = lead_vehicle_data.Position(j) - data.Position(j);
                end
            end

            % 後続車両の距離を計算
            if ~isnan(follow_vehicle_id) && follow_vehicle_id > 0
                follow_vehicle_file = fullfile(output_folder, sprintf('vehicle_%d.csv', follow_vehicle_id));
                if isfile(follow_vehicle_file)
                    follow_vehicle_data = readtable(follow_vehicle_file);
                    FollowDistance(j) = data.Position(j) - follow_vehicle_data.Position(j);
                end
            end
        end

        % 距離のプロット
        figure(4);
        plot(Time, LeadDistance, 'DisplayName', ['Lead Distance (Vehicle ' num2str(vehicle_id) ')'], 'LineWidth', 2);
        plot(Time, FollowDistance, 'DisplayName', ['Follow Distance (Vehicle ' num2str(vehicle_id) ')'], 'LineWidth', 2, 'LineStyle', '--');
        legend show;
    end
end