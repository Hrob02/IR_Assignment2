classdef RobotMovement
    properties
        robot; % Robot model object
        steps = 50; % Number of steps for the animation
    end
    
    methods
        % Constructor to initialize the RobotMovement object
        function obj = RobotMovement(robotModel)
            obj.robot = robotModel;
        end
        
        % Method to move the robot to a specific joint configuration
        function MoveToJointConfiguration(obj, qValues)
            % Check if the qValues provided match the number of joints
            if length(qValues) ~= obj.robot.model.n
                error('The joint configuration must have %d values corresponding to the robot joints.', obj.robot.model.n);
            end
    
            % Generate trajectory from the current position to the desired qValues
            qCurrent = obj.robot.model.getpos();
            path = jtraj(qCurrent, qValues, obj.steps);
    
            % Animate the movement along the path
            for i = 1:obj.steps
                obj.robot.model.animate(path(i, :));
                drawnow;
            end
        end
    end
end
