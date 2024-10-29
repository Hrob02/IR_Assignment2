classdef collisionAvoidance
    properties
        Tolerance = 0.05; % Define a tolerance for collision detection
        PointClouds; % Property to store PLY point clouds
    end
    
    methods
        function obj = collisionAvoidance(plyFiles)
            % Load PLY point clouds only once during initialization
            obj.PointClouds = cell(size(plyFiles));
            for i = 1:length(plyFiles)
                obj.PointClouds{i} = pcread(plyFiles{i});
            end
        end
        
        function crash = CheckCollision(obj, EndEffectorPos, plyIndex)
            % Get the current position of the robot as a 3D vector
            currentPos = EndEffectorPos;

            % Get the PLY point cloud for the given index
            ptCloud = obj.PointClouds{plyIndex};

            % Get limits of the point cloud
            xyzLimits = [ptCloud.XLimits; ptCloud.YLimits; ptCloud.ZLimits];

            % Check if the current position is within specified limits with tolerance
            withinXlim = (currentPos(1) >= (xyzLimits(1, 1) - obj.Tolerance)) && ...
                          (currentPos(1) <= (xyzLimits(1, 2) + obj.Tolerance));
            withinYlim = (currentPos(2) >= (xyzLimits(2, 1) - obj.Tolerance)) && ...
                          (currentPos(2) <= (xyzLimits(2, 2) + obj.Tolerance));
            withinZlim = (currentPos(3) >= (xyzLimits(3, 1) - obj.Tolerance)) && ...
                          (currentPos(3) <= (xyzLimits(3, 2) + obj.Tolerance));

            withinLimits = withinXlim && withinYlim && withinZlim;

            if withinLimits
                crash = true; % Collision detected
                disp("Crash detected");
            else
                crash = false; % No collision
            end
            pause(0.1);
        end
    end
end
