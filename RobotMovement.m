% classdef RobotMovement
% 
%     %  RobotMovement handles the robots movements based on input joint configurations.
% 
%     properties
%         robot;      % Robot model object
%         steps = 50; % Number of steps for animation %% can change
%         % exchangePositionsRed = shared array of the dobot final place
%             % position and the robot pick position.
%         % exchangePositionsGreen = 
%         % cameraPlace = again shared to place infront of the camera for
%             % analysis
%         % sortPositions = {-2,y,0.5; -2,y,0.5; -2,y,0.5; -2,y,0.5;};
%             % order red large, red small, green large, green small
%         qGuess = [0,0,0,0,0,0,0]; % for forward kinematics to reduce unwanted movement
%         qInitial;
% 
%     end
% 
%     methods
%         % Constructor to initialize the robot object and steps if provided
%         function obj = RobotMovement(robotModel) % , exchangePositionsRed, cameraPlace, exchangePositionsGreen
%             if nargin > 0
%                 obj.robot = robotModel;
%                 obj.steps = steps;
%                 obj.qGuess = qGuess;
%                 obj.qInitial = obj.robot.model.getpos();
%                 % obj.exchangePositionsRed
%                 % obj.exchangePositionsGreen
%                 % obj.exchangePositions
%                 % obj.cameraPlace
%             end
%         end
% 
%         % Method to perform the movement from an initial to a final configuration
%         function MoveToConfiguration(obj, q_initial, q_final)
%             % Generate trajectory from initial to final configuration
%             path = jtraj(q_initial, q_final, obj.steps);
% 
%             % Animate the movement
%             for i = 1:obj.steps
%                 obj.robot.model.animate(path(i, :));
%                 drawnow;
%             end
%         end
%     end
% end
classdef RobotMovement
    % RobotMovement handles the robot's movements based on input joint configurations.

    properties
        robot; % Robot model object
        steps = 50; % Number of steps for animation
        exchangePositionsRed; % Position for picking red gems
        exchangePositionsGreen; % Position for picking green gems
        cameraPlace; % Position to place the gem for camera analysis
        sortPositions; % Positions for sorting the gems (order: red large, red small, green large, green small)
        qGuess = [0,0,0,0,0,0,0]; % Initial guess for forward kinematics
        qInitial; % Initial joint configuration of the robot
    end

    methods
        % Constructor to initialize the robot object and properties
        function obj = RobotMovement(robotModel)
            if nargin > 0
                obj.robot = robotModel;
                obj.steps = 50;
                obj.qGuess = [0,0,0,0,0,0,0];
                obj.qInitial = obj.robot.model.getpos();
                % Define exchange and sort positions (example values)
                obj.exchangePositionsRed = SE3(0.4, 0.3, 0.5);
                obj.exchangePositionsGreen = SE3(0.4, -0.3, 0.5);
                obj.cameraPlace = SE3(0.2, 0, 0.5);
                obj.sortPositions = [SE3(0.6, 0.4, 0.5), SE3(0.6, 0.3, 0.5), ...
                                     SE3(0.6, -0.4, 0.5), SE3(0.6, -0.3, 0.5)];
            end
        end

        % Method to move the robot from an initial to a final configuration
        function MoveToConfiguration(obj, q_initial, q_final)
            % Generate trajectory from initial to final configuration
            path = jtraj(q_initial, q_final, obj.steps);
            % Animate the movement
            for i = 1:obj.steps
                obj.robot.model.animate(path(i, :));
                drawnow;
            end
        end

        % Method to pick and place a gem based on its color
        function PickAndPlaceGem(obj, gemColor)
            % Determine the exchange position based on gem color
            if strcmp(gemColor, 'red')
                exchangePosition = obj.exchangePositionsRed;
            elseif strcmp(gemColor, 'green')
                exchangePosition = obj.exchangePositionsGreen;
            else
                error('Invalid gem color specified');
            end

            % Move to the exchange position to pick the gem
            qExchange = obj.robot.model.ikcon(exchangePosition.T, obj.qGuess);
            obj.MoveToConfiguration(obj.qInitial, qExchange);
            
            % Close the gripper to pick up the gem
            disp('suction pick up the gem');
            
            % Move to the camera position for analysis
            qCamera = obj.robot.model.ikcon(obj.cameraPlace.T, obj.qGuess);
            obj.MoveToConfiguration(qExchange, qCamera);
            
            % Assume gem size determination (example: use gem color to decide)
            if strcmp(gemColor, 'red')
                gemSize = 'large';
            else
                gemSize = 'small';
            end

            % Move to the appropriate sort position
            obj.SortGem(gemColor, gemSize);
        end

        % Method to sort a gem based on color and size
        function SortGem(obj, gemColor, gemSize)
            % Determine the sort position based on gem color and size
            if strcmp(gemColor, 'red') && strcmp(gemSize, 'large')
                sortPosition = obj.sortPositions(1);
            elseif strcmp(gemColor, 'red') && strcmp(gemSize, 'small')
                sortPosition = obj.sortPositions(2);
            elseif strcmp(gemColor, 'green') && strcmp(gemSize, 'large')
                sortPosition = obj.sortPositions(3);
            elseif strcmp(gemColor, 'green') && strcmp(gemSize, 'small')
                sortPosition = obj.sortPositions(4);
            else
                error('Invalid gem color or size specified');
            end

            % Move to the sort position and release the gem
            qSort = obj.robot.model.ikcon(sortPosition.T, obj.qGuess);
            obj.MoveToConfiguration(obj.qInitial, qSort);
            disp('Suction release gem');
        end

        % Method to execute the sorting task for multiple gems
        function ExecuteSortingTask(obj)
            gemList = {'red', 'green', 'red', 'green'}; % Example list of gems
            for i = 1:length(gemList)
                gemColor = gemList{i};
                obj.PickAndPlaceGem(gemColor);
                obj.qInitial = obj.robot.model.getpos(); % Update initial position
            end
        end
    end
end
