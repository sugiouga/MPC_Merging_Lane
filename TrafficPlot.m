Y_offset = 0.0;
Xminp = 0;
Xmaxp = 1600;

plt = [];

% メインレーンの車両をプロット
main_vehicles = values(MainLane.Vehicles); % メインレーンの車両リストを取得
for i = 1:length(main_vehicles)
    vehicle = main_vehicles{i};
    x = vehicle.position; % 車両の位置
    y = 1 + Y_offset; % メインレーンのY座標
    plt(end+1) = plot(x, y, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerEdgeColor', 'k');
end

% サブレーンの車両をプロット
sub_vehicles = values(SubLane.Vehicles); % サブレーンの車両リストを取得
for i = 1:length(sub_vehicle_positions)
    vehicle = sub_vehicles{i};
    x = vehicle.position; % 車両の位置
    y =  Y_offset + (4-3./(1.+exp(-0.02*(x-800.0)))); % サブレーンのY座標
    plt(end+1) = plot(x, y, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'MarkerEdgeColor', 'k');
end

% タイトルと軸の設定
Msg = sprintf('Simulation time 00:%d:%02d', floor(dt * (KK - 1) / 60), mod(floor(dt * (KK - 1)), 60));
title(Msg);
axis([Xminp, Xmaxp, 0.0, 5 + Y_offset]);
grid on;
xlabel('X');
M(fm) = getframe(hFig);
fm = fm + 1;