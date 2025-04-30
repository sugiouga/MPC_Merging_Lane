function Save_Vehicle_State_to_CSV(vehicle, time, output_folder)
    % ビークルの状態をCSVファイルに保存する
    filename = fullfile(output_folder, sprintf('vehicle_%d.csv', vehicle.Vehicle_ID));

    % ビークルの状態を取得
    data = [time, vehicle.position, vehicle.velocity, vehicle.acceleration, vehicle.jerk, vehicle.Lead_Vehicle_ID, vehicle.Follow_Vehicle_ID, vehicle.Lane_ID];

    % ヘッダーを追加 (ファイルが存在しない場合のみ)
    if ~isfile(filename)
        header = {'Time', 'Position', 'Velocity', 'Acceleration', 'Jerk', 'Lead_Vehicle_ID', 'Follow_Vehicle_ID', 'Lane_ID'};
        writecell(header, filename);
    end

    % データを追記
    writematrix(data, filename, 'WriteMode', 'append');
end