classdef collisionAvoidance
    properties
        Tolerance = 0.05; % Define a tolerance for collision detection
    end
    
    methods
        function obj = collisionAvoidance()
            obj.Tolerance;
        end
        
        function crash = CheckCollision(obj, EndEffectorPos, plyFile)
            % Get the current position of the robot as a 3D vector
            currentPos = EndEffectorPos;
        
            % Read the PLY point cloud
            ptCloud = pcread(plyFile);
        
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
        
            % Optionally display the point cloud for visualization
            hold on;
            PtCloudTrans = pointCloud(ptCloud.Location + currentPos); % Translate point cloud to the end effector position
            pcshow(PtCloudTrans); % Show translated point clouds
        
            pause(0.1);
        end
    end
end
