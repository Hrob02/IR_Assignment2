classdef ABBMovement
    properties
        %a;
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
        CamCart = [-0.7,-1.2,0.65];
        ExRedCart = [-0.67,-1.85,0.48];
        ExGreenCart = [-0.67,-1.7,0.48];
        DropCart = [-1.82,-1.35,0.53;
            -1.82,-1.5,0.53;
            -1.82,-1.65,0.53;
            -1.82,-1.8,0.53];
        InitialCart;
    end
    
    methods
        % Constructor to initialize the ABBMovement object
        function obj = ABBMovement(gems, robotModel, eStopController)%,aHardware)
            %obj.a=aHardware;
            obj.gems = gems;
            obj.robot = robotModel;
            obj.eStopController = eStopController;
            obj.q_pickup_green;
            obj.q_pickup_red;
            obj.q_dropoff_ABB;
            obj.currentGem = []; % Initialize as empty
            obj.CamCart;
            obj.ExRedCart;
            obj.ExGreenCart;
            obj.DropCart;
            obj.InitialCart;
        end

        function ExecuteRobot(obj, gemIndex)
            qInitial = obj.robot.model.getpos();
            obj.InitialCart = obj.robot.model.fkine(qInitial).t;
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                obj.PickGemABB(gemIndex);
                obj.AnalyzeGem(gemIndex);
                obj.PlaceGemSorting(gemIndex);
            end
            % q = [0 -pi/2 0 0 0 0 0];
            obj.MoveToJointConfiguration(obj.InitialCart',qInitial);
        end


        function PickGemABB(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.currentGem = obj.gems(gemIndex);
                color = obj.currentGem.color;
                if strcmp(color, 'red')
                    pickupq = obj.q_pickup_red;
                    ExPos = obj.ExRedCart;
                elseif strcmp(color, 'green')
                    pickupq = obj.q_pickup_green;
                    ExPos = obj.ExGreenCart;
                else
                    disp(['Unknown color detected: ', color]);
                    return;
                end
                obj.MoveToJointConfiguration(ExPos,pickupq);
                disp(['ABB Robot picking up Gem ',  num2str(gemIndex)]);
                pause(2);  % Wait for 2 second
            end
        end

        % Method to analyze the gem using the camera
        function AnalyzeGem(obj, gemIndex)
            if gemIndex > 0 && gemIndex <= length(obj.gems)
                obj.MoveToJointConfiguration(obj.CamCart, obj.q_cam);
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
                    SortCart = obj.DropCart(1,:);
                elseif strcmp(color, 'red') && strcmp(GemSize,'large')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for large Red Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(2,:);
                    SortCart = obj.DropCart(2,:);
                elseif strcmp(color, 'green') && strcmp(GemSize,'small')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for small Green Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(3,:);
                    SortCart = obj.DropCart(3,:);
                elseif strcmp(color, 'green') && strcmp(GemSize,'large')
                    disp(['Gem color: ', color]);
                    disp(['Gem size: ', GemSize]);
                    pause(1);
                    disp('ABB Robot moving to drop-off location for large Green Gem.');
                    pause(1);
                    exchangeq = obj.q_dropoff_ABB(4,:);
                    SortCart = obj.DropCart(4,:);
                end
            
                % Move to the determined exchange position
                obj.MoveToJointConfiguration(SortCart, exchangeq);
                % Simulate placing the gem at the exchange position
                % obj.currentGem.isSorted = true; % Mark the gem as sorted
                pause(2);
                disp(['Gem placed at final position for ', GemSize,' ', color, ' gem.']);
                obj.currentGem = []; % Clear the current gem after placing
            end
        end

        function MoveToQJointConfiguration(obj, qValues)
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
        
                drawnow;  % Refresh the plot
        
                i = i + 1;  % Increment the loop index
            end
        end

        function MoveToJointConfiguration(obj, pos, qValues)
            qCurrent = obj.robot.model.getpos();
            if isequal(pos,obj.CamCart)
                position = transl(pos(1),pos(2),pos(3))*trotx(pi/2);
            elseif isequal(pos,obj.InitialCart)
                position = transl(pos(1),pos(2),pos(3));
            else
                position = transl(pos(1),pos(2),pos(3)+0.05);
            end
            qFinal=obj.robot.model.ikcon(position* trotx(pi),qValues);
            path = jtraj(qCurrent, qFinal, obj.steps);

            i=1;
            
            % Loop through each step in the trajectory
            while i <= obj.steps
                % % Read the button state
                % buttonStateEStop = readDigitalPin(obj.a, "D8");
                % 
                % % Check if the button is pressed and debounce
                % if buttonStateEStop == 1
                %     pause(0.1); % Debounce delay (100 ms)
                %     if readDigitalPin(obj.a, "D8") == 1 % Check again to confirm E-Stop button press
                %         obj.eStopController.eStopEngaged = true; % Engage E-Stop
                %         disp('Movement halted due to emergency stop.');
                % 
                %         % Wait until the emergency stop is disengaged
                %         while obj.eStopController.eStopEngaged
                %             pause(0.1);  % Small pause to avoid busy-waiting
                % 
                %             % Check the state of the resume button
                %             buttonStateResume = readDigitalPin(obj.a, "D12");  % Read resume button state
                % 
                %             if buttonStateResume == 1
                %                 pause(0.1); % Debounce delay
                %                 if readDigitalPin(obj.a, "D12") == 1 % Check again to confirm resume button press
                %                     obj.eStopController.eStopEngaged = false; % Disengage E-Stop
                %                 end
                %             end
                %         end
                %         buttonStateEStop = 0;  
                %         disp('Resuming movement...');
                %     end
                % end


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

                m = zeros(1, obj.steps-1);           % Manipulability measure
                %errorValue = zeros(3, obj.steps-1);  % Velocity error

                % Calculate the Jacobian
                J = obj.robot.model.jacob0(jointConfig);
                J_t = J(1:3, :);

                lambda = 0.1;  % damping factor

                % Get the next joint configuration
                if i < obj.steps
                    nextJoint = path(i + 1, :);
                    deltaT = obj.robot.model.fkine(nextJoint).T - obj.robot.model.fkine(jointConfig).T;
                    xdot = deltaT(1:3, 4);

                    % Calculate manipulability
                    m(i) = sqrt(det(J_t * J_t'));  % Using the Frobenius norm  
        
                    % Manipulability check and speed reduction
                    if m(i) < 1e-4
                        speedReductionFactor = 0.5;  % Reduce speed to 50%
                        xdot = xdot * speedReductionFactor;
                        disp(['Reducing speed at step ', num2str(i), ' due to low manipulability.']);
                        pause(0.1)
                        disp('Increasing allowable error and Changing Trajectory');

                        % Joint velocity calculation with damping
                        qdot = pinv(J_t' * J_t + lambda^2 * eye(size(J_t, 2))) * J_t' * xdot;
                        path(i+1,:) = path(i,:)+qdot';
                        pause(0.1);

                        % Calculate velocity error
                        %errorValue(:, i) = xdot - J_t * qdot; 
                    end
        
                    % Display results for debugging
                    % disp(['Step ', num2str(i), ': Jacobian J_t =']);
                    % disp(J_t);
                    % disp(['Step ', num2str(i), ': xdot = ', num2str(xdot')]);
                    % disp(['Step ', num2str(i), ': qdot = ', num2str(qdot')]);
                    % disp(['Step ', num2str(i), ': Manipulability = ', num2str(m(i))]);
                    % disp(['Step ', num2str(i), ': Velocity Error = ', num2str(errorValue(:, i)')]);
                end
        
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
