classdef Controller
    % Controller 車両の制御器を表すクラス
    methods(Static)
        function acceleration = IDM(current_velocity, lead_vehicle_position, lead_vehicle_velocity, current_position)
            % IDM: インテリジェントドライバーモデルに基づく加速度を計算するメソッド
            
            % パラメータ設定
            desired_velocity = 30; % 目標速度 (m/s)
            minimum_spacing = 2; % 最小車間距離 (m)
            time_headway = 1.5; % 時間的車間距離 (s)
            max_acceleration = 1.5; % 最大加速度 (m/s^2)
            comfortable_deceleration = 2; % 快適減速度 (m/s^2)
            delta = 4; % 加速度指数

            % 現在の車間距離を計算
            gap = lead_vehicle_position - current_position;

            % 安全な車間距離を計算
            desired_gap = minimum_spacing + max(0, current_velocity * time_headway + ...
                (current_velocity * (current_velocity - lead_vehicle_velocity)) / ...
                (2 * sqrt(max_acceleration * comfortable_deceleration)));

            % IDM に基づく加速度を計算
            if gap > 0
                acceleration = max_acceleration * (1 - (current_velocity / desired_velocity)^delta - (desired_gap / gap)^2);
            else
                acceleration = -comfortable_deceleration; % 車間距離が負の場合は減速
            end
        end
    end
end