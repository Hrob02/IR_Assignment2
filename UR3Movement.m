classdef UR3Movement 
    properties
        UR3; % UR3 model
        steps = 50; % Number of steps for the animation
    end
    
    methods
        % Constructor to initialize the UR3Movement object
        function obj = UR3Movement(UR3Model)
            obj.UR3 = UR3Model;
        end
        
        % Method to move the UR3e robot to a specific joint configuration
        function MoveToJointConfiguration(obj, qValues)
            % Check if the qValues provided match the number of joints
            if length(qValues) ~= obj.UR3.model.n
                error('The joint configuration must have %d values corresponding to the robot joints.', obj.UR3.model.n);
            end
    
            % Generate trajectory from the current position to the desired qValues
            qCurrent = obj.UR3.model.getpos();
            path = jtraj(qCurrent, qValues, obj.steps);
    
            % Animate the movement along the path
            for i = 1:obj.steps
                obj.UR3.model.animate(path(i, :));
                drawnow;
            end
        end
    end
end