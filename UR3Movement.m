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
        
        function MoveToPosition(obj, position)
            % Convert the (x, y, z) position into a homogeneous transformation
            targetTransform = transl(position(1), position(2), position(3));
            % Solve for joint configuration using IK

            currentq = obj.UR3.model.getpos();

            qFinal = obj.UR3.model.ikcon(targetTransform * trotx(pi), currentq);
        
            % Generate trajectory using jtraj
            path = jtraj(currentq, qFinal, obj.steps);
            
            % Animate the movement
            for i = 1:obj.steps
                
                obj.UR3.model.animate(path(i, :));
                
                %currentTransform = obj.UR3.model.fkine(path(i, :));
                
                if isequal(targetTransform(1:3,4)', obj.cameraPosition) || isequal(targetTransform(1:3,4)', obj.exchangePositions)
                    obj.gems.attachToEndEffector(); % Update the gem position
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
                
                end
            
            end
        end

        % Method to analyze the gem using the camera
        function AnalyzeGem(obj)
            % Move to the camera position for analysis
            obj.MoveToPosition(obj.cameraPosition);
            % Placeholder for color analysis logic
            disp('Analyzing gem color...');
        end
        
        function PlaceGemAtExchange(obj)
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

        function ExecuteTask(obj)
            for i = 1:length(obj.gems)
                % Only attempt to pick gems that are not sorted
                if ~obj.gems(i).isSorted
                    % Pick the gem
                    obj.PickGem(i);
                    % Analyze the gem color
                    obj.AnalyzeGem();
                    % Place gem at the corresponding exchange position
                    obj.PlaceGemAtExchange();
                end
            end
            disp('Gem sorting task completed.');
        end
    end
end
