classdef ABBMovement
    properties
        gems;
        robot; % Robot model object
        steps = 50; % Number of steps for the animation
        eStopController; % Reference to the shared emergency stop controller
        q_cam =[-0.02 0 pi/2 -3*pi/10 pi/2 pi/2 0];
        q_dropoff_green = [-0.5, 0, 17*pi/40, 0, 25*pi/360, -pi/2, 0];  % Dropoff for green gems
        q_dropoff_red = [-0.7, 0, 17*pi/40, 0, 25*pi/360, -pi/2, 0];    % Dropoff for red gems
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
            obj.q_dropoff_green;
            obj.q_dropoff_red;
            obj.q_dropoff_ABB;
            obj.currentGem = []; % Initialize as empty
        end

        function ExecuteRobot(obj)
            pause(1);
            size(obj.gems)
            for i = 1:length(obj.gems)
                obj.currentGem = obj.gems(i);
                % while obj.currentGem.isSorted == false % Check if the current gem is sorted
                %     pause(1); % Optional: wait for a second before checking again
                % end
                % disp(['Executing ABB robot for gem index: ', num2str(i)]);
                obj.PickGemABB(i);
                obj.AnalyzeGem(i);
                obj.PlaceGemSorting(i);
            end
            q=zeros(1,7);
            obj.MoveToJointConfiguration(q);
        end


        function PickGemABB(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    pickupq = obj.q_dropoff_red;
                elseif strcmp(color, 'green')
                    pickupq = obj.q_dropoff_green;
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
            qCurrent = obj.robot.model.getpos();
            path = jtraj(qCurrent, qValues, obj.steps);

            for i = 1:obj.steps
                if obj.eStopController.eStopEngaged
                    disp('Movement halted due to emergency stop.');
                    while obj.eStopController.eStopEngaged
                        pause(0.1);
                    end
                    disp('Resuming movement...');
                end
                
                obj.robot.model.animate(path(i, :));
                jointConfig = path(i,:);
                targetTransform = obj.robot.model.fkine(qValues).T;
                currentTransform = obj.robot.model.fkine(jointConfig).T;
                cameraPosition = obj.robot.model.fkine(obj.q_cam).T;
                SortRedsmol = obj.robot.model.fkine(obj.q_dropoff_ABB(1,:)).T;
                SortRedbig = obj.robot.model.fkine(obj.q_dropoff_ABB(2,:)).T;
                SortGreensmol = obj.robot.model.fkine(obj.q_dropoff_ABB(3,:)).T;
                SortGreenbig = obj.robot.model.fkine(obj.q_dropoff_ABB(4,:)).T;
               
                if isequal(targetTransform(1:3,4)', cameraPosition(1:3,4)') || isequal(targetTransform(1:3,4)', SortRedsmol(1:3,4)')|| isequal(targetTransform(1:3,4)', SortGreensmol(1:3,4)')|| isequal(targetTransform(1:3,4)', SortRedbig(1:3,4)')|| isequal(targetTransform(1:3,4)', SortGreenbig(1:3,4)')
                    obj.currentGem.attachToEndEffector(currentTransform); % Pass the current transform
                end
                drawnow;
            end
        end
    end
end
