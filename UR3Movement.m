classdef UR3Movement
    properties
        UR3; % UR3 model
        initialGemPositions; % Initial positions for the gems
        cameraPosition; % Position for camera analysis
        exchangePositions; % Positions to place gems after sorting by color
        gems; % Array of gem objects
        currentGem; % The gem currently being manipulated
        steps = 50; % Number of steps for the animation
    end
    
    methods
        % Constructor to initialize the UR3Movement object
        function obj = UR3Movement(UR3Model, initialGemPositions, cameraPosition, exchangePositions, gems)
            if nargin == 5  % Ensure that all parameters are passed
                obj.UR3 = UR3Model;
                obj.initialGemPositions = initialGemPositions;
                obj.cameraPosition = cameraPosition;
                obj.exchangePositions = exchangePositions;
                obj.gems = gems; % Check that gems are initialized correctly
                obj.currentGem = []; % Initialize as empty
            else
                error('All parameters must be provided to UR3Movement constructor.');
            end
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
            
            disp('Robot moved to the specified joint configuration.');
        end
            
       function MoveToPosition(obj, position)
            % Convert the (x, y, z) position into a homogeneous transformation
            targetTransform = transl(position(1), position(2), position(3));
            % Solve for joint configuration using IK
            qFinal = obj.UR3.model.ikcon(targetTransform*trotx(pi), obj.UR3.model.getpos());
           
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

        
        function PickGem(obj, gemIndex)
            % Check if the gem index is within range and if it's not already sorted
            if gemIndex > 0 && gemIndex <= length(obj.gems) && ~obj.gems(gemIndex).isSorted
                % Get the gem to pick
                obj.currentGem = obj.gems(gemIndex);
                if isa(obj.currentGem, 'Gem')
                    disp(['Picking gem: ', num2str(gemIndex)]);
                    % Move to the initial position of the gem
                    obj.MoveToPosition(obj.currentGem.position);
                    % Move the gem to the end-effector position
                    endEffectorTransform = obj.UR3.model.fkine(obj.UR3.model.getpos());
                    gemPosition = endEffectorTransform(1:3, 4).'; % Get the position of the end effector
                    obj.currentGem.MoveToPosition(gemPosition); % Move the gem to the end-effector
                    disp('Gem picked successfully.');
                else
                    error('The selected object is not a valid Gem.');
                end
            else
                error('Gem index out of range or gem already sorted.');
            end
        end

        
        % Method to analyze the gem using the camera
        function AnalyzeGem(obj)
            % Move to the camera position for analysis
            obj.MoveToPosition(obj.cameraPosition);
            % Placeholder for color analysis logic
            disp('Analyzing gem color...');
        end
        
        function PlaceGemAtExchange(obj, robotMovement)
            if isempty(obj.currentGem)
                error('No gem is currently held.');
            end
            if ~isa(obj.currentGem, 'Gem')
                error('The current gem is not a valid Gem object.');
            end
        
            color = obj.currentGem.color;
            if strcmp(color, 'red')
                exchangePos = obj.exchangePositions.red(1, :);
            elseif strcmp(color, 'green')
                exchangePos = obj.exchangePositions.green(1, :);
            else
                disp(['Unknown color detected: ', color]);
                return;
            end
        
            % Move to the determined exchange position
            obj.MoveToPosition(exchangePos);
            % Simulate placing the gem at the exchange position
            obj.currentGem.MoveToPosition(exchangePos);
            obj.currentGem.isSorted = true; % Mark the gem as sorted
            disp(['Gem placed at exchange position for ', color, ' gem.']);
            obj.currentGem = []; % Clear the current gem after placing
        end

        function ExecuteTask(obj, robotMovement)
            for i = 1:length(obj.gems)
                % Only attempt to pick gems that are not sorted
                if ~obj.gems(i).isSorted
                    % Pick the gem
                    obj.PickGem(i);
                    % Analyze the gem color
                    obj.AnalyzeGem();
                    % Place gem at the corresponding exchange position
                    obj.PlaceGemAtExchange(robotMovement);
                end
            end
            disp('Gem sorting task completed.');
        end
    end
end
