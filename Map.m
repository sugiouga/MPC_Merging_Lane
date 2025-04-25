classdef Map<handle

    properties(GetAccess = 'public', SetAccess = 'private')
        % Map 地図情報を表すクラス
        Map_ID = [] % 地図のID
        Lanes = [] % 道路リスト
    end

    methods

        function obj = Map(Map_ID)
            % 地図の初期化
            obj.Map_ID = Map_ID;
            obj.Lanes = dictionary; % 道路リスト
        end

        function add_Lane(obj, Lane)
            % 道路を地図に追加
            obj.Lanes(Lane.Lane_ID) = Lane; % 道路を地図に追加
        end

        function get_lead_vehicle(obj, Vehicle_ID)
            % 車両の最も近い先行車両を取得
            if isKey(obj.Lanes, Vehicle_ID)
                Lane = obj.Lanes(Vehicle_ID);
                lead_vehicle = []; % 前方車両の初期化
                min_distance = inf; % 最小距離の初期化

                % 前方車両を検索
                keys = obj.Lanes.keys;
                for i = 1:length(keys)
                    other_lane = obj.Lanes(keys(i));
                    other_vehicle = other_lane.get_lead_vehicle(Vehicle_ID);
                    if ~isempty(other_vehicle) && other_vehicle.position < min_distance
                        lead_vehicle = other_vehicle;
                        min_distance = other_vehicle.position;
                    end
                end
            else
                error('Lane ID not found in the map!');
            end
        end

    end
end