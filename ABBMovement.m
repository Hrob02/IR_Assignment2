classdef ABBMovement
    properties
        gems;
        robot; % Robot model object
        steps = 50; % Number of steps for the animation
        eStopController; % Reference to the shared emergency stop controller
        q_cam =[-0.02 0 pi/2 -3*pi/10 pi/2 pi/2 0];
        q_pickup_green = [-0.5 0 pi/2 -7*pi/20 0 7*pi/20 0];   % Pickup for green gems
        q_pickup_red = [-0.7 0 pi/2 -7*pi/20 0 7*pi/20 0];    % Pickup for red gems
        q_dropoff_ABB = [
           -0.1, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for red small gems
           -0.3, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for red large gems
           -0.5, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for green small gems
           -0.7, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for green large gems
        ];
        currentGem;
    end
    
    methods
        % Constructor to initialize the ABBMovement object
        function obj = ABBMovement(gems, robotModel, eStopController)
            obj.gems = gems;
            obj.robot = robotModel;
            obj.eStopController = eStopController;
            obj.q_pickup_green;
            obj.q_pickup_red;
            obj.q_dropoff_ABB;
            obj.currentGem = []; % Initialize as empty
        end

        function ExecuteRobot(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                obj.PickGemABB(gemIndex);
                obj.AnalyzeGem(gemIndex);
                obj.PlaceGemSorting(gemIndex);
            end
            q = [0 -pi/2 0 0 0 0 0];
            obj.MoveToJointConfiguration(q);
        end


        function PickGemABB(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    pickupq = obj.q_pickup_red;
                elseif strcmp(color, 'green')
                    pickupq = obj.q_pickup_green;
                else
                    disp(['Unknown color detected: ', color]);
                    return;
                end
                obj.MoveToJointConfiguration(pickupq);
                disp(['ABB Robot picking up Gem ',  num2str(gemIndex)]);
                pause(2);  % Wait for 2 second
            end
        end

        % Method to analyze the gem using the camera
        function AnalyzeGem(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.MoveToJointConfiguration(obj.q_cam);
                disp(['ABB Robot analyzing Gem ', num2str(gemIndex), ' at the camera.']);
                pause(2);
            end
        end

        function PlaceGemSorting(obj, gemIndex)
            % Check if the gem index is valid
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
      
                color = obj.currentGem.color;
                GemSize = obj.currentGem.size;
                if strcmp(color, 'red') && strcmp(GemSize, 'small')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for small Red Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(1,:);
                elseif strcmp(color, 'red') && strcmp(GemSize,'large')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for large Red Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(2,:);
                elseif strcmp(color, 'green') && strcmp(GemSize,'small')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for small Green Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(3,:);
                elseif strcmp(color, 'green') && strcmp(GemSize,'large')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for large Green Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(4,:);
                end
            
                % Move to the determined exchange position
                obj.MoveToJointConfiguration(exchangeq);
                % Simulate placing the gem at the exchange position
                % obj.currentGem.isSorted = true; % Mark the gem as sorted
                pause(2);
                disp(['Gem placed at final position for ', GemSize,' ', color, ' gem.']);
                obj.currentGem = []; % Clear the current gem after placing
            end
        end

        function MoveToJointConfiguration(obj, qValues)
            qCurrent = obj.robot.model.getpos();  % Get current joint positions
            path = jtraj(qCurrent, qValues, obj.steps);  % Generate a joint trajectory
        
            i = 1;  % Initialize the loop index
        
            % Loop through each step in the trajectory
            while i <= obj.steps
                % Check if emergency stop is engaged
                if obj.eStopController.eStopEngaged
                    disp('Movement halted due to emergency stop.');
        
                    % Wait until the emergency stop is disengaged
                    while obj.eStopController.eStopEngaged
                        pause(0.1);  % Introduce a small pause to avoid busy-waiting
                    end
                    
                    disp('Resuming movement...');
                end
        
                % Animate the robot to the current step of the trajectory
                obj.robot.model.animate(path(i, :));
                jointConfig = path(i, :);  % Get the current joint configuration
        
                % Calculate and check the current and target transforms
                targetTransform = obj.robot.model.fkine(qValues).T;
                currentTransform = obj.robot.model.fkine(jointConfig).T;
                cameraPosition = obj.robot.model.fkine(obj.q_cam).T;
                SortRedsmol = obj.robot.model.fkine(obj.q_dropoff_ABB(1, :)).T;
                SortRedbig = obj.robot.model.fkine(obj.q_dropoff_ABB(2, :)).T;
                SortGreensmol = obj.robot.model.fkine(obj.q_dropoff_ABB(3, :)).T;
                SortGreenbig = obj.robot.model.fkine(obj.q_dropoff_ABB(4, :)).T;
        
                % Attach the current gem if the position matches certain target locations
                if isequal(targetTransform(1:3, 4)', cameraPosition(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', SortRedsmol(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', SortGreensmol(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', SortRedbig(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', SortGreenbig(1:3, 4)')
                    obj.currentGem.attachToEndEffector(currentTransform);  % Attach the gem at the current transform
                end
        
                drawnow;  % Refresh the plot
        
                i = i + 1;  % Increment the loop index
            end
        end
    end
end
