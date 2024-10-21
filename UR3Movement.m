classdef UR3Movement
    properties
        UR3; % Dobot model
        initialGemPositions; % Initial positions for the gems
        cameraPosition; % Position for camera analysis
        exchangePositions; % Positions to place gems after sorting by color
        gems; % Array of gem objects
        currentGem; % The gem currently being manipulated
        steps = 50; % Number of steps for the animation
    end
    
    methods
        % Constructor to initialize the Dobot object and properties
        function obj = UR3Movement(UR3Model, initialGemPositions, cameraPosition, exchangePositions, gems)
            if nargin > 0
                obj.UR3 = UR3Model;
                obj.steps = 50;
                obj.initialGemPositions = initialGemPositions;
                obj.cameraPosition = cameraPosition;
                obj.exchangePositions = exchangePositions;
                obj.gems = gems;
                obj.currentGem = []; % Initialize as empty
            end
        end
        
        function MoveToPosition(obj, position)
            % Convert the (x, y, z) position into a homogeneous transformation
            targetTransform = transl(position(1), position(2), position(3));
            % Solve for joint configuration using IK
            qFinal = obj.UR3.model.ikcon(targetTransform, obj.UR3.model.getpos());
            
            % Validate the resulting joint configuration
            if isempty(qFinal) || length(qFinal) ~= obj.UR3.model.n
                error('Inverse kinematics failed to find a valid solution.');
            end
            
            % Generate trajectory using jtraj
            path = jtraj(obj.UR3.model.getpos(), qFinal, obj.steps);
            
            % Animate the movement
            for i = 1:obj.steps
                obj.UR3.model.animate(path(i, :));
                
                % Calculate the current end-effector position using fkine
                try
                    currentTransform = obj.UR3.model.fkine(path(i, :));
                catch
                    error('Forward kinematics calculation failed.');
                end
                
                % Ensure the currentTransform is a valid 4x4 matrix
                if size(currentTransform, 1) == 4 && size(currentTransform, 2) == 4
                    % Extract the end-effector position using a transpose
                    gemPosition = currentTransform(1:3, 4).'; % Transpose to convert column to row vector
                    if ~isempty(obj.currentGem) && isa(obj.currentGem, 'Gem')
                        obj.currentGem.MoveToPosition(gemPosition);
                    end
                else
                    % If the transformation matrix is not valid, display a warning
                    warning('The transformation matrix for the robot''s end effector is not of size 4x4.');
                end
                
                drawnow;
            end
        end
        
        % Method to pick a gem
        function PickGem(obj, gemIndex)
            % Check if the gem index is within range
            if gemIndex <= length(obj.gems)
                % Get the gem to pick
                obj.currentGem = obj.gems(gemIndex);
                if isa(obj.currentGem, 'Gem')
                    disp(['Picking gem: ', num2str(gemIndex)]);
                    % Move to the initial position of the gem
                    obj.MoveToPosition(obj.currentGem.position);
                    % Attach gem to the end effector after reaching its position
                    disp('Gem picked successfully.');
                else
                    error('The selected object is not a valid Gem.');
                end
            else
                error('Gem index out of range.');
            end
        end
        
        % Method to analyze the gem using the camera
        function AnalyzeGem(obj)
            % Move to the camera position for analysis
            obj.MoveToPosition(obj.cameraPosition);
            % Placeholder for color analysis logic
            disp('Analyzing gem color...');
        end
        
        % Method to place the gem at an exchange position based on the assigned color
        function PlaceGemAtExchange(obj, robotMovement)
            if isempty(obj.currentGem)
                error('No gem is currently held.');
            end
            if ~isa(obj.currentGem, 'Gem')
                error('The current gem is not a valid Gem object.');
            end

            color = obj.currentGem.color;
            if strcmp(color, 'red')
                exchangePos = obj.exchangePositions.red(1, :); % Use the first available position
            elseif strcmp(color, 'green')
                exchangePos = obj.exchangePositions.green(1, :); % Use the first available position
            else
                disp(['Unknown color detected: ', color]);
                return;
            end
            
            % Move to the determined exchange position
            obj.MoveToPosition(exchangePos);
            % Simulate placing the gem at the exchange position
            obj.currentGem.MoveToPosition(exchangePos);
            % Notify the robot movement system that a gem is available for sorting
            robotMovement.gemAvailable = true;
            disp(['Gem placed at exchange position for ', color, ' gem.']);
            % Clear the currentGem after placing
            obj.currentGem = [];
        end

        % Execute the task of sorting gems
        function ExecuteTask(obj, robotMovement)
            for i = 1:length(obj.gems)
                % Pick the gem
                obj.PickGem(i);
                % Analyze the gem color
                obj.AnalyzeGem();
                % Place gem at the corresponding exchange position
                obj.PlaceGemAtExchange(robotMovement);
            end
            disp('Gem sorting task completed.');
        end
    end
end
