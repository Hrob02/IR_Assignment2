classdef RobotMovement 
    properties
        UR3;
        robot; % Robot model object
        steps = 50; % Number of steps for the animation
        eStopController; % Reference to the shared emergency stop controller
        gems;
        currentGem;
        q_cam = [-0.2, pi, -pi/2, 0, 0, 0, 0];
        q_pickup_UR3 =[
            -0.1, pi, 17*pi/40, 0, 25*pi/360, -pi/2, 0;  % Pickup for Gem(1)
            -0.3, pi, 17*pi/40, 0, 25*pi/360, -pi/2, 0;  % Pickup for Gem(2)
            -0.5, pi, 17*pi/40, 0, 25*pi/360, -pi/2, 0;  % Pickup for Gem(3)
            -0.7, pi, 17*pi/40, 0, 25*pi/360, -pi/2, 0;  % Pickup for Gem(4)
            -0.64, 0, -17*pi/40, 0, -25*pi/360, pi/2, 0; % Pickup for Gem(5)
            -0.8, 0, -17*pi/40, 0, -25*pi/360, pi/2, 0;  % Pickup for Gem(6)
        ];
        q_dropoff_green = [-0.5, 0, 17*pi/40, 0, 25*pi/360, -pi/2, 0];  % Dropoff for green gems
        q_dropoff_red = [-0.7, 0, 17*pi/40, 0, 25*pi/360, -pi/2, 0];    % Dropoff for red gems
        q_dropoff_ABB = [
           -0.1, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for red small gems
           -0.3, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for red large gems
           -0.5, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for green small gems
           -0.7, pi, pi/2, -9*pi/20, 0, 9*pi/20, 0;  % Dropoff for green large gems
        ];
        CamCart;
        PickCart;
        ExCart;
        SortCart;


    end
    
    methods
        % Constructor to initialize the RobotMovement object
        function obj = RobotMovement(gems, UR3Model, robotModel, eStopController)
            obj.UR3 = UR3Model;
            obj.robot = robotModel;
            obj.eStopController = eStopController;
            obj.gems = gems;
            obj.currentGem = []; % Initialize as empty
            obj.q_cam;
            obj.q_pickup_UR3;
            obj.q_dropoff_green;
            obj.q_dropoff_red;
            obj.q_dropoff_ABB;
            obj.CamCart;  % for later we should be using positon x,y,z according to assignment some small changes to logic required
            obj.PickCart;
            obj.ExCart;
            obj.SortCart;
        end

        %execute UR3
        function ExecuteUR3(obj, ~)
            for i = 1:length(obj.gems)
                obj.currentGem = obj.gems(i);
                    obj.PickGemUR3(i);
                    obj.AnalyzeGem(i);
                    obj.PlaceGemAtExchange(i);
                    % Check if the gem is sorted and execute ABB robot movement
                if obj.currentGem.isSorted
                    obj.ExecuteRobot(i,obj.robot); % Call the new method to execute ABB
                end
            end
            disp('Gem sorting task completed.');
        end

        %execute Robot
        function ExecuteRobot(obj, gemIndex, ~)
            disp(['Executing ABB robot for gem index: ', num2str(gemIndex)]);
            obj.PickGemABB(gemIndex);
            obj.AnalyzeGem(gemIndex);
            obj.PlaceGemSorting(gemIndex);
        end


        function PickGemUR3(obj,gemIndex)
            % Check if the gem index is within range and if it's not already sorted
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                % Get the gem to pick
                obj.currentGem = obj.gems(gemIndex);
                % Move to the initial position of the gem
                obj.MoveToJointConfiguration(obj.q_pickup_UR3(gemIndex,:));
            end
        end

        function PickGemABB(obj,gemIndex)
            size(obj.gems)
            % Check if the gem index is within range and if it's not already sorted
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                % Get the gem to pick
                obj.currentGem = obj.gems(gemIndex);
                % Move to the initial position of the gem
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    pickupq = obj.q_dropoff_red;
                elseif strcmp(color, 'green')
                    pickupq = obj.q_dropoff_green;
                else
                    disp(['Unknown color detected: ', color]);
                    return;
                end
                obj.MoveToJointConfiguration(pickupq(gemIndex,:));
            end
        end

        % Method to analyze the gem using the camera
        function AnalyzeGem(obj, gemIndex)
            % Check if the gem index is valid
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                obj.MoveToJointConfiguration(obj.q_cam);
                % Placeholder for color analysis logic
                disp(['Analyzing gem color for gem: ', num2str(gemIndex)]);
            end
        end

        function PlaceGemAtExchange(obj, gemIndex)
            % Check if the gem index is valid
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
      
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    exchangeq = obj.q_dropoff_red;
                elseif strcmp(color, 'green')
                    exchangeq = obj.q_dropoff_green;
                else
                    disp(['Unknown color detected: ', color]);
                    return;
                end
            
                % Move to the determined exchange position
                obj.MoveToJointConfiguration(exchangeq);
                % Simulate placing the gem at the exchange position
                obj.currentGem.isSorted = true; % Mark the gem as sorted
                disp(['Gem placed at exchange position for ', color, ' gem.']);
                obj.currentGem = []; % Clear the current gem after placing
            end
        end

        function PlaceGemSorting(obj, gemIndex)
            % Check if the gem index is valid
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
      
                color = obj.currentGem.color;
                GemSize = obj.currentGem.size;
                if strcmp(color, 'red') && strcmp(GemSize, 'small')
                    exchangeq = obj.q_dropoff_ABB(1);
                elseif strcmp(color, 'red') && strcmp(GemSize,'Large')
                    exchangeq = obj.q_dropoff_ABB(2);
                elseif strcmp(color, 'green') && strcmp(GemSize,'small')
                    exchangeq = obj.q_dropoff_ABB(3);
                else
                    exchangeq = obj.q_dropoff_ABB(4);
                end
            
                % Move to the determined exchange position
                obj.MoveToJointConfiguration(exchangeq);
                % Simulate placing the gem at the exchange position
                obj.currentGem.isSorted = true; % Mark the gem as sorted
                disp(['Gem placed at exchange position for ', color, ' gem.']);
                obj.currentGem = []; % Clear the current gem after placing
            end
        end
        
        % Method to move the robot to a specific joint configuration
        function MoveToJointConfiguration(obj, qValues)
    
            % Generate trajectory from the current position to the desired qValues
            qCurrent = obj.robot.model.getpos();
            path = jtraj(qCurrent, qValues, obj.steps);
    
            % Animate the movement along the path
            for i = 1:obj.steps
                % Check if e-stop is engaged
                if obj.eStopController.eStopEngaged
                    disp('Movement halted due to emergency stop.');
                    while obj.eStopController.eStopEngaged
                        pause(0.1); % Wait until e-stop is disengaged
                    end
                    disp('Resuming movement...');
                end
                
                % Animate the movement step
                obj.robot.model.animate(path(i, :));
                jointConfig = path(i,:);
                targetTransform = obj.robot.model.fkine(qValues).T;
                currentTransform = obj.robot.model.fkine(jointConfig).T;
                cameraPosition = obj.robot.model.fkine(obj.q_cam).T;
                exchangePositionsRed = obj.robot.model.fkine(obj.q_dropoff_red).T;
                exchangePositionsGreen = obj.robot.model.fkine(obj.q_dropoff_green).T;
               
                if isequal(targetTransform(1:3,4)', cameraPosition(1:3,4)') || isequal(targetTransform(1:3,4)', exchangePositionsRed(1:3,4)')|| isequal(targetTransform(1:3,4)', exchangePositionsGreen(1:3,4)')
                    obj.currentGem.attachToEndEffector(currentTransform); % Pass the current transform
                end
                drawnow;
            end
        end
    end
end
