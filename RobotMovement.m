classdef RobotMovement

    %  RobotMovement handles the robots movements based on input joint configurations.

    properties
        robot;      % Robot model object
        steps = 50; % Number of steps for animation %% can change
    end
    
    methods
        % Constructor to initialize the robot object and steps if provided
        function obj = RobotMovement(robotModel, steps)
            if nargin > 0
                obj.robot = robotModel;
            end
            if nargin > 1
                obj.steps = steps;
            end
        end
        
        % Method to perform the movement from an initial to a final configuration
        function MoveToConfiguration(obj, q_initial, q_final)
            % Generate trajectory from initial to final configuration
            path = jtraj(q_initial, q_final, obj.steps);
            
            % Animate the movement
            for i = 1:obj.steps
                obj.robot.model.animate(path(i, :));
                drawnow;
            end
        end
    end
end
