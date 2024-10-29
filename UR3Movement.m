classdef UR3Movement
    properties
        gems;
        UR3;
        steps = 50; % Number of steps for the animation
        eStopController; % Reference to the shared emergency stop controller
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
        currentGem;
        CamCart = [-0.7,-1.2,0.65];
        ExRedCart = [-0.67,-1.85,0.48];
        ExGreenCart = [-0.67,-1.7,0.48];
        initialCart;
    end
    
    methods
        % Constructor to initialize the UR3Movement object
        function obj = UR3Movement(gems, UR3Model, eStopController)
            obj.gems = gems;
            obj.UR3 = UR3Model;
            obj.eStopController = eStopController;
            obj.q_pickup_UR3;
            obj.q_dropoff_green;
            obj.q_dropoff_red;
            obj.currentGem = []; % Initialize as empty
            obj.CamCart;
            obj.ExRedCart;
            obj.ExGreenCart;
            obj.initialCart;
        end

       function ExecuteUR3(obj, gemIndex)
           qInitial = obj.UR3.model.getpos();
           obj.initialCart = obj.UR3.model.fkine(qInitial).t;
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                obj.PickGemUR3(gemIndex);
                obj.AnalyzeGem(gemIndex);
                obj.PlaceGemAtExchange(gemIndex);
            end
            obj.MoveToJointConfiguration(obj.initialCart',qInitial);
        end

        function PickGemUR3(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.q_pickup_UR3)
                obj.currentGem = obj.gems(gemIndex);
                PickCart = obj.currentGem.position;
                obj.MoveToJointConfiguration(PickCart,obj.q_pickup_UR3(gemIndex,:));
                disp(['UR3 Robot picking up Gem ',  num2str(gemIndex)]);
                pause(2);  % Wait for 2 second
            end
        end

        function AnalyzeGem(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.q_pickup_UR3)
                obj.MoveToJointConfiguration(obj.CamCart, obj.q_cam);
                disp(['UR3 Robot analyzing Gem ', num2str(gemIndex), ' at the camera.']);
                pause(2);
            end
        end

        function PlaceGemAtExchange(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.q_pickup_UR3)
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    exchangeq = obj.q_dropoff_red;
                    ExPos = obj.ExRedCart;
                elseif strcmp(color, 'green')
                    exchangeq = obj.q_dropoff_green;
                    ExPos = obj.ExGreenCart;
                else
                    disp(['Unknown color detected: ', color]);
                    return;
                end

                disp(['Gem color: ', color]);
                pause(1);
                disp(['UR3 Robot moving to drop-off location for ', color,' Gem.']);
                obj.MoveToJointConfiguration(ExPos, exchangeq);
                obj.currentGem.isSorted = true; % Mark the gem as sorted
                disp(['Gem placed at exchange position for ', color, ' gem.']);
                obj.currentGem = []; % Clear the current gem after placing
            end
            pause(2);
        end

        function MoveToQJointConfiguration(obj, qValues)
            qCurrent = obj.UR3.model.getpos();  % Get current joint positions
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
                obj.UR3.model.animate(path(i, :));
        
                drawnow;  % Refresh the plot
        
                i = i + 1;  % Increment the loop index
            end
        end

        function MoveToJointConfiguration(obj, pos, qValues)
            qCurrent = obj.UR3.model.getpos();
            if isequal(pos,obj.CamCart)
                position = transl(pos(1),pos(2),pos(3))*trotx(pi/2);
            elseif isequal(pos,obj.initialCart)
                position = transl(pos(1),pos(2),pos(3));
            else
                position = transl(pos(1),pos(2),pos(3)+0.05);
            end
            qFinal=obj.UR3.model.ikcon(position* trotx(pi),qValues);
            path = jtraj(qCurrent, qFinal, obj.steps);

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
                obj.UR3.model.animate(path(i, :));
                jointConfig = path(i, :);  % Get the current joint configuration
        
                % Calculate and check the current and target transforms
                targetTransform = obj.UR3.model.fkine(qValues).T;
                currentTransform = obj.UR3.model.fkine(jointConfig).T;
                cameraPosition = obj.UR3.model.fkine(obj.q_cam).T;
                exchangePositionsRed = obj.UR3.model.fkine(obj.q_dropoff_red).T;
                exchangePositionsGreen = obj.UR3.model.fkine(obj.q_dropoff_green).T;
        
                % Attach the current gem if the position matches certain target locations
                if isequal(targetTransform(1:3, 4)', cameraPosition(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', exchangePositionsRed(1:3, 4)') || ...
                   isequal(targetTransform(1:3, 4)', exchangePositionsGreen(1:3, 4)')
                    obj.currentGem.attachToEndEffector(currentTransform);  % Attach the gem at the current transform
                end
        
                drawnow;  % Refresh the plot
        
                i = i + 1;  % Increment the loop index
            end
        end
    end
end
