classdef RobotMovement
    % RobotMovement handles the robot's movements and gem sorting tasks.

    properties
        robot; % Robot model object
        steps = 50; % Number of steps for animation
        exchangePositionsRed; % Positions for picking red gems
        exchangePositionsGreen; % Positions for picking green gems
        cameraPlace; % Position for camera analysis
        sortPositions; % Positions for sorting (red large, red small, green large, green small)
        qGuess = [0, 0, 0, 0, 0, 0, 0]; % Guess for inverse kinematics
        qInitial; % Initial joint configuration
        gems; % Array of gem objects
        currentGem; % Currently manipulated gem
        gemAvailable = false; % Flag to indicate if a gem is available for sorting
    end

    methods
        % Constructor to initialize the robot object and properties
        function obj = RobotMovement(robotModel, sortPositions, gems, status)
            if nargin > 0
                obj.robot = robotModel;
                obj.steps = 50;
                obj.qGuess = [0, 0, 0, 0, 0, 0, 0];
                obj.qInitial = obj.robot.model.getpos();
                obj.sortPositions = sortPositions;
                obj.gems = gems;
                obj.gemAvailable = status;
            end
        end

        % Method to move the robot from an initial to a final configuration
        function MoveToConfiguration(obj, q_initial, q_final)
            % Generate trajectory using jtraj
            path = jtraj(q_initial, q_final, obj.steps);
            % Animate the movement
            for i = 1:obj.steps
                obj.robot.model.animate(path(i, :));
                % If a gem is currently being picked, move it with the end effector
                if ~isempty(obj.currentGem)
                    obj.currentGem.MoveToPosition(transl(obj.robot.model.fkine(path(i, :))));
                end
                drawnow;
            end
        end

        % Method to move to a specified (x, y, z) position using IK
        function MoveToPosition(obj, position)
            % Convert the (x, y, z) position into a homogeneous transformation
            targetTransform = transl(position(1), position(2), position(3));
            % Solve for joint configuration using IK
            qFinal = obj.robot.model.ikcon(targetTransform, obj.robot.model.getpos());
            obj.qGuess = qFinal; % Update the guess for the next calculation

            % Move to the calculated joint configuration
            obj.MoveToConfiguration(obj.robot.model.getpos(), qFinal);
        end

        % Method to pick a gem
        function PickGem(obj, gemIndex)
            if obj.gemAvailable
                % Attach gem to end effector
                obj.currentGem = obj.gems(gemIndex);
                disp(['Picking gem: ', num2str(gemIndex)]);
                % Move to the initial position of the gem
                obj.MoveToPosition(obj.currentGem.position);
                % Placeholder for suction activation
                disp('Suction activated to pick up gem.');
                obj.gemAvailable = false; % Reset availability status after picking up
            else
                disp('No gem available to pick up.');
            end
        end

        % Method to place a gem at a specified position
        function PlaceGem(obj, position)
            if ~isempty(obj.currentGem)
                % Move to the specified position
                obj.MoveToPosition(position);
                % Place the gem at the specified position
                obj.currentGem.MoveToPosition(position);
                % Release the gem
                obj.currentGem = [];
                disp('Gem placed successfully and suction deactivated.');
            else
                disp('No gem is currently being held.');
            end
        end

        % Method to sort a gem based on size and color
        function SortGem(obj, gemIndex, sortPosition)
            % Wait until a gem is available
            if obj.gemAvailable
                % Pick the specified gem
                obj.PickGem(gemIndex);
                % Move to the sort position and release the gem
                obj.PlaceGem(sortPosition);
            else
                disp('Gem is not available for sorting.');
            end
        end

        % Execute sorting tasks for all gems
        function ExecuteSortingTask(obj)
            % Sort red gems
            for i = 1:size(obj.exchangePositionsRed, 1)
                % Determine the appropriate sort position for the red gem
                sortPosition = obj.sortPositions{mod(i-1, 2) + 1}; % Red positions (1 or 2)
                obj.SortGem(i, sortPosition);
            end

            % Sort green gems
            for i = 1:size(obj.exchangePositionsGreen, 1)
                gemIndex = size(obj.exchangePositionsRed, 1) + i;
                % Determine the appropriate sort position for the green gem
                sortPosition = obj.sortPositions{mod(i-1, 2) + 3}; % Green positions (3 or 4)
                obj.SortGem(gemIndex, sortPosition);
            end
            disp('Gem sorting task completed.');
        end
    end
end

