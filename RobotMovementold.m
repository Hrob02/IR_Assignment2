classdef RobotMovement < handle
    properties
        robot; % Robot model object
        steps = 50; % Number of steps for the animation
        eStopController; % Reference to the shared emergency stop controller
    end
    
    methods
        % Constructor to initialize the RobotMovement object
        function obj = RobotMovement(robotModel, eStopController)
            obj.robot = robotModel;
            obj.eStopController = eStopController;
            
            % Add listeners for the e-stop controller
            addlistener(eStopController, 'EStopEngaged', @(src, event) obj.HaltMovement());
            addlistener(eStopController, 'EStopDisengaged', @(src, event) obj.ResumeMovement());
        end
        
        % Method to move the robot to a specific joint configuration
        function MoveToJointConfiguration(obj, qValues)
            % Check if the qValues provided match the number of joints
            if length(qValues) ~= obj.robot.model.n
                error('The joint configuration must have %d values corresponding to the robot joints.', obj.robot.model.n);
            end
    
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
                drawnow;
            end
        end
        
        % Method to halt movement when e-stop is engaged
        function HaltMovement(obj)
            % Code to handle what happens when the emergency stop is engaged
            disp('Listener: Emergency stop engaged. Robot movement halted.');
        end
        
        % Method to resume movement when e-stop is disengaged
        function ResumeMovement(obj)
            % Code to handle what happens when the emergency stop is disengaged
            disp('Listener: Emergency stop disengaged. Resuming movement.');
        end
    end
end
