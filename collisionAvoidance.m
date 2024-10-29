classdef collisionAvoidance
    properties
        % Define any necessary properties here
    end
    
    methods
        function obj = collisionAvoidance()
            % Constructor for the CollisionAvoidance class
        end
        
        function crash = CheckCollision(obj, robot, xyzLimits, plyFile, positionxyz)
            % Get the current position of the robot as a 3D vector
            currentPos = robot.fkine(robot.getpos).t; 

            % Check if the current position is within specified limits
            withinXlim = (currentPos(1) >= xyzLimits(1, 1)) && (currentPos(1) <= xyzLimits(1, 2));
            withinYlim = (currentPos(2) >= xyzLimits(2, 1)) && (currentPos(2) <= xyzLimits(2, 2));
            withinZlim = (currentPos(3) >= xyzLimits(3, 1)) && (currentPos(3) <= xyzLimits(3, 2));

            withinLimits = withinXlim && withinYlim && withinZlim; 

            if withinLimits
                crash = true;
                disp("Crash");
            else
                crash = false;
            end
            
            % Validate position input
            if size(positionxyz, 2) ~= 3
                error('Invalid position input. Ensure format is [x, y, z]');
            end
            
            hold on

            % Reading PLY point clouds
            ptCloud = pcread(plyFile); 
            PtCloudTrans = pointCloud(ptCloud.Location + positionxyz); % Translate point clouds

            pcshow(PtCloudTrans); % Show translated point clouds

            % Update xyzLimits with point cloud limits
            xyzLimits = [PtCloudTrans.XLimits; PtCloudTrans.YLimits; PtCloudTrans.ZLimits];

            % Optionally place the object at the new position
            % obj.PlaceObject(plyFile, positionxyz);

            pause(0.1);
        end
        
        % function PlaceObject(~, plyFile, positionxyz)
        %     % Your existing PlaceObject implementation
        %     % Add the implementation details here as needed
        % end
    end
end
