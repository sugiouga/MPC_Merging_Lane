config;

Y_offset = 0.0;
Xminp = 0;
Xmaxp = 1600;

plt = [];

% メインレーンの車両をプロット
mainlane_vehicles = values(MainLane.Vehicles);
for vehicle = mainlane_vehicles'
    x = vehicle.position; % 車両の位置
    y = 1 + Y_offset; % メインレーンのY座標
    plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0 0.4470 0.7410]);
    plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0 0.4470 0.7410]);
    if vehicle.Vehicle_ID > 100
        plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
        plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    end
end

% サブレーンの車両をプロット
sublane_vehicles = values(SubLane.Vehicles);
for vehicle = sublane_vehicles'
    x = vehicle.position; % 車両の位置
    y =  Y_offset + (4-3./(1.+exp(-0.02*(x-800.0)))); % サブレーンのY座標
    plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
end

% タイトルと軸の設定
Msg = sprintf('Simulation time 00:%d:%02d', floor(TIME_STEP * (step - 1) / 60), mod(floor(TIME_STEP * (step - 1)), 60));
title(Msg);
axis([Xminp, Xmaxp, 0.0, 5 + Y_offset]);
grid on;
xlabel('X');
M(fm) = getframe(hFig);
fm = fm + 1;
