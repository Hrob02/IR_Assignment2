classdef DobotMovement
    properties
        Dobot;
    end
    methods
        function obj = DobotMovement(Dobot)
            if nargin > 0
                obj.Dobot = Dobot;
            end
        end

        function executeTask(obj)
            % information for Dobot movement
        end
    end
end

