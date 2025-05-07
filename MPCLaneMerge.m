clear
close all

config;
LaneMerge = Map('MPCLaneMerge'); % 地図の初期化

MainLane = Lane('MainLane', 0, 1600, 25); % メインレーンの初期化
SubLane = Lane('SubLane', 0, 1000, 20); % サブレーンの初期化

LaneMerge.add_Lane(MainLane); % メインレーンの追加
LaneMerge.add_Lane(SubLane); % サブレーンの追加

% メインレーンの車両を追加
for VEHICLE_ID = 1:5
    % 車両をメインレーンに追加
    MainLane.add_Vehicle(Vehicle(VEHICLE_ID, 'CAR'), 800 - 150 * VEHICLE_ID, 25);
end

% サブレーンの車両を追加
for VEHICLE_ID = 1:1
    % 車両をサブレーンに追加
    SubLane.add_Vehicle(Vehicle(VEHICLE_ID + 100, 'CAR'), 600 -100 * VEHICLE_ID, 20);
end

hFig=figure; set(hFig, 'position', [20,300,1000,200]);
Garea1=[0,2000]; Garea2=[5.5,5.5]+1;
area(Garea1,Garea2, 'FaceColor',[0.65 0.995 0.95]); hold on;

% 結果を保存するフォルダを作成
output_folder = 'result';
if exist(output_folder, 'dir')
    rmdir(output_folder, 's'); % フォルダを削除
end
mkdir(output_folder); % 新しいフォルダを作成

% 動画保存の設定
video_filename = fullfile(output_folder, 'simulation_record.avi');
video_writer = VideoWriter(video_filename);
open(video_writer);

% 道路の描画
xr1=2.:50:2000; % 道路位置
yr1=(4-3./(1.+exp(-0.02*(xr1-800.0)))); % 道路形状の曲線
plot(xr1,yr1,'LineWidth',10,'Color',[0.7 0.7 0.7]);
plot([5;2000], [1;1],'LineWidth',10,'Color',[0.7 0.7 0.7]);

fm = 1;
plt = [];

% シミュレーション時間のループ
for step = 1 : 600
    if(mod(step, 4)==1)
        delete(plt);
        TrafficPlot;

    end

    % フレームを動画に追加
    frame = getframe(hFig);
    writeVideo(video_writer, frame);

    time = step * TIME_STEP; % 現在の時間

    % メインレーン車両の更新
    mainlane_vehicles = values(MainLane.Vehicles);
    for vehicle = mainlane_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        % if vehicle.VEHICLE_ID > 100 && vehicle.position < 1200
        if vehicle.VEHICLE_ID > 100 && vehicle.position < 1600
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            follow_vehicle_in_MainLane = MainLane.get_follow_vehicle(vehicle.position);
            vehicle.mpc(lead_vehicle_in_MainLane, follow_vehicle_in_MainLane, 0.3);
        else
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            vehicle.constant_speed(vehicle.REFERENCE_VELOCITY);
        end

        vehicle.update();

        % if vehicle.position > MainLane.end_position
        %     MainLane.remove_Vehicle(vehicle.VEHICLE_ID);
        % end
    end

    % サブレーン車両の更新
    sublane_vehicles = values(SubLane.Vehicles);
    for vehicle = sublane_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        if vehicle.position > 800
            lead_vehicle_in_MainLane = MainLane.get_lead_vehicle(vehicle.position);
            follow_vehicle_in_MainLane = MainLane.get_follow_vehicle(vehicle.position);
            vehicle.mpc(lead_vehicle_in_MainLane, follow_vehicle_in_MainLane, 0.3);
        else
            lead_vehicle_in_SubLane = SubLane.get_lead_vehicle(vehicle.position);
            vehicle.idm(lead_vehicle_in_SubLane);
        end

        vehicle.update();

        if vehicle.position > 900
            MainLane.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
            SubLane.remove_Vehicle(vehicle.VEHICLE_ID);
        end
    end

    if isempty(mainlane_vehicles) && isempty(sublane_vehicles)
        break;
    end
end

% 動画保存を終了
close(video_writer);
PlotVehicleData;

close all;

function save_vehicle_state_to_csv(Vehicle, time, output_folder)
    % ビークルの状態をCSVファイルに保存する
    filename = fullfile(output_folder, sprintf('vehicle_%d.csv', Vehicle.VEHICLE_ID));

    % ビークルの状態を取得
    data = [time, Vehicle.position, Vehicle.velocity, Vehicle.acceleration, Vehicle.jerk, Vehicle.Follow_VEHICLE_ID, Vehicle.Lead_VEHICLE_ID, Vehicle.status];

    % ヘッダーを追加 (ファイルが存在しない場合のみ)
    if ~isfile(filename)
        header = {'Time', 'Position', 'Velocity', 'Acceleration', 'Jerk', 'Follow_Vehicle_ID', 'Lead_Vehicle_ID', 'Status'};
        writecell(header, filename);
    end

    % データを追記
    writematrix(data, filename, 'WriteMode', 'append');
end