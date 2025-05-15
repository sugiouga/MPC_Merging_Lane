plt = [];

% 本線の車両をプロット
mainline_vehicles = values(MainLine.Vehicles);
for vehicle = mainline_vehicles'
    x = vehicle.position; % 車両の位置
    y = 1 + Y_OFFSET; % 本線のY座標
    if contains(vehicle.VEHICLE_ID, 'MainLine')
        plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0 0.4470 0.7410]);
        plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0 0.4470 0.7410]);
    elseif contains(vehicle.VEHICLE_ID, 'OnRamp')
        plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
        plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    end
end

% 合流車線の車両をプロット
onramp_vehicles = values(OnRamp.Vehicles);
for vehicle = onramp_vehicles'
    x = vehicle.position; % 車両の位置
    y =  Y_OFFSET + (4-2.8./(1.+exp(-0.02*(x-200.0)))); % 合流車線のY座標
    plt(end+1) = plot(x, y, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    plt(end+1)=plot(x-3, y, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0.8500 0.3250 0.0980]);
end

% タイトルと軸の設定
Msg = sprintf('Simulation time 00:%d:%02d', floor(TIME_STEP * (step - 1) / 60), mod(floor(TIME_STEP * (step - 1)), 60));
title(Msg);
axis([X_MIN, X_MAX, 0.0, 5 + Y_OFFSET]);
grid on;
xlabel('X');
M(fm) = getframe(hFig);
fm = fm + 1;
