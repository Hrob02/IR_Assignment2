classdef RobotMovement

    %  RobotMovement handles the robots movements based on input joint configurations.

    properties
        robot;      % Robot model object
        steps = 50; % Number of steps for animation %% can change
        % exchangePositions = shared array of the dobot final place
            % position and the robot pick position.
        % cameraPlace = again shared to place infront of the camera for
            % analysis
        % sortPositions = {-2,y,0.5; -2,y,0.5; -2,y,0.5; -2,y,0.5;};
            % order red large, red small, green large, green small
        qGuess = [0,0,0,0,0,0,0]; % for forward kinematics to reduce unwanted movement
        qInitial;

    end
    
    methods
        % Constructor to initialize the robot object and steps if provided
        function obj = RobotMovement(robotModel, steps)
            if nargin > 0
                obj.robot = robotModel;
                obj.steps = steps;
                obj.qGuess = qGuess;
                obj.qInitial = obj.robot.model.getpos();
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
