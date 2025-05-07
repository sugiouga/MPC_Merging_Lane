classdef Map<handle

    properties(GetAccess = 'public', SetAccess = 'private')
        % Map 地図情報を表すクラス
        MAP_ID = [] % 地図のID
        Lanes = [] % 道路リスト
    end

    methods

        function obj = Map(MAP_ID)
            % 地図の初期化
            obj.MAP_ID = MAP_ID;
            obj.Lanes = dictionary; % 道路リスト
        end

        function add_Lane(obj, Lane)
            % 道路を地図に追加
            obj.Lanes(Lane.LANE_ID) = Lane; % 道路を地図に追加
        end

    end
end