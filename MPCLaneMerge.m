clear
close all

config;
LaneMerge = Map('MPCLaneMerge'); % 地図の初期化

MainLine = Lane('MainLine', 0, 500, 25); % 本線の初期化
OnRamp = Lane('OnRamp', 0, 400, 20); % 合流車線の初期化

LaneMerge.add_Lane(MainLine); % 本線の追加
LaneMerge.add_Lane(OnRamp); % 合流車線の追加

% 本線の車両を追加
for id = 1:16
    MainLine_Vehicle_Distance = 60; % 車両間隔 (m)
    MainLine_Vehicle_Speed = 15; % 車両速度 (m/s)
    % 車両を本線に追加
    MainLine.add_Vehicle(Vehicle(sprintf('MainLine_Vehicle_%d', id), 'CAR'), MainLine.END_POSITION - MainLine_Vehicle_Distance*(id - 1), MainLine_Vehicle_Speed);
end

% 合流車線の車両を追加
for id = 1:1
    OnRamp_Vehicle_Distance = 100; % 車両間隔 (m)
    OnRamp_Vehicle_Speed = 10; % 車両速度 (m/s)
    % 車両を合流車線に追加
    OnRamp.add_Vehicle(Vehicle(sprintf('OnRamp_Vehicle_%d', id), 'CAR'), - OnRamp_Vehicle_Distance*(id - 1), OnRamp_Vehicle_Speed);
end

hFig=figure; set(hFig, 'position', [20,300,1000,200]);
Garea1=[0,500]; Garea2=[5.5,5.5]+1;
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
xr1=0.:50:450; % 道路位置
yr1=(4-2.8./(1.+exp(-0.02*(xr1-200.0)))); % 道路形状の曲線
plot(xr1,yr1,'LineWidth',10,'Color',[0.7 0.7 0.7]);
plot([0;500], [1;1],'LineWidth',10,'Color',[0.7 0.7 0.7]);

fm = 1;
plt = [];

% シミュレーション時間のループ
for step = 1 : 300
    if(mod(step, 5)==1)
        delete(plt);
        TrafficPlot;

    end

    % フレームを動画に追加
    frame = getframe(hFig);
    writeVideo(video_writer, frame);

    time = step * TIME_STEP; % 現在の時間

    % 本線車両の更新
    mainline_vehicles = values(MainLine.Vehicles);
    for vehicle = mainline_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        lead_vehicle_in_MainLine = MainLine.get_lead_vehicle(vehicle.position);
        vehicle.idm(lead_vehicle_in_MainLine);

        vehicle.update();

    end

    % 合流車線車両の更新
    onlamp_vehicles = values(OnRamp.Vehicles);
    for vehicle = onlamp_vehicles'
        % ビークルの状態をCSVに保存
        save_vehicle_state_to_csv(vehicle, time, output_folder);

        if vehicle.position > 0
            lead_vehicle_in_MainLine = MainLine.get_lead_vehicle(vehicle.position);
            follow_vehicle_in_MainLine = MainLine.get_follow_vehicle(vehicle.position);
            vehicle.mpc(lead_vehicle_in_MainLine, follow_vehicle_in_MainLine);
        else
            lead_vehicle_in_OnLamp = OnRamp.get_lead_vehicle(vehicle.position);
            vehicle.idm(lead_vehicle_in_OnLamp);
        end

        vehicle.update();

        if vehicle.position > 400
            MainLine.add_Vehicle(vehicle, vehicle.position, vehicle.velocity);
            OnRamp.remove_Vehicle(vehicle.VEHICLE_ID);
        end
    end

    if isempty(mainline_vehicles) && isempty(onlamp_vehicles)
        break;
    end
end

% 動画保存を終了
close(video_writer);
close all;
PlotVehicleData;

function save_vehicle_state_to_csv(Vehicle, time, output_folder)
    % ビークルの状態をCSVファイルに保存する
    filename = fullfile(output_folder, sprintf('%s.csv', Vehicle.VEHICLE_ID));

    % ビークルの状態を取得
    data = [time, Vehicle.position, Vehicle.velocity, Vehicle.acceleration, Vehicle.jerk];

    % ヘッダーを追加 (ファイルが存在しない場合のみ)
    if ~isfile(filename)
        header = {'Time', 'Position', 'Velocity', 'Acceleration', 'Jerk'};
        writecell(header, filename);
    end

    % データを追記
    writematrix(data, filename, 'WriteMode', 'append');
end