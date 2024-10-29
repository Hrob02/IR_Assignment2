function moveEndEffector(robot, xEnd)
    % External function to move the end-effector of a given robot instance

    % Get current joint positions of the robot model
    qCurrent = robot.model.getpos();
    
    % Get current end-effector position
    currentPose = robot.model.fkine(qCurrent);
    currentPos = transl(currentPose);
    
    % Set up the initial Cartesian positions
    xStart = currentPos(1:3)';  % Extract initial (x, y, z) from current position
    
    % Define the number of steps and time interval
    steps = 100;
    dt = 0.1;  % Time interval between each step
    
    % Generate a linear Cartesian trajectory
    xTrajectory = [linspace(xStart(1), xEnd(1), steps); 
                   linspace(xStart(2), xEnd(2), steps); 
                   linspace(xStart(3), xEnd(3), steps)];
    
    % Initial joint configuration is the current configuration
    q = qCurrent;
    
    % Damping coefficient to handle singularities
    lambda = 0.1;
    
    % RMRC loop to move the end-effector from xStart to xEnd
    for i = 1:steps
        % Compute the desired velocity of the end-effector (in Cartesian space)
        if i < steps
            dx_linear = (xTrajectory(:, i + 1) - xTrajectory(:, i)) / dt;
        else
            dx_linear = [0; 0; 0];  % Stop at the end of the trajectory
        end
        
        % Combine linear and angular velocities (assuming no rotational movement)
        dx = [dx_linear; 0; 0; 0];  % 6-element vector [vx; vy; vz; wx; wy; wz]
        
        % Get the current Jacobian matrix for the robot at the current joint configuration
        J = robot.model.jacob0(q);  % Jacobian for the current configuration
        
        % Compute the joint velocities using the damped least squares method
        J_damped = J' / (J * J' + lambda^2 * eye(size(J, 1)));
        dq = J_damped * dx;
        
        % Update the joint configuration
        q = q + (dq' * dt);
        
        % Ensure joint limits are respected
        for j = 1:length(q)
            if q(j) < robot.model.qlim(j, 1)
                q(j) = robot.model.qlim(j, 1);
            elseif q(j) > robot.model.qlim(j, 2)
                q(j) = robot.model.qlim(j, 2);
            end
        end
        
        % Update the robot model with the new joint configuration
        robot.model.animate(q);
        drawnow;
    end
    
    % ---- Verification Section ----
    % Calculate the final end-effector position using forward kinematics
    finalTransform = robot.model.fkine(q);
    finalPosition = transl(finalTransform);  % Extract the x, y, z position
    
    % Print the final position of the end-effector
    disp('Final End-Effector Position:');
    disp(finalPosition);
    
    % Check if the final position matches the desired end point (within a small tolerance)
    tolerance = 1e-3;  % Set a small tolerance
    if all(abs(finalPosition' - xEnd) < tolerance)
        disp('The robot successfully reached the desired end point.');
    else
        disp('The robot did not reach the exact desired end point.');
    end
    
    % Check if the final joint configuration is within the robot's joint limits
    withinLimits = true;
    for j = 1:length(q)
        if q(j) < robot.model.qlim(j, 1) || q(j) > robot.model.qlim(j, 2)
            withinLimits = false;
            disp(['Joint ', num2str(j), ' is out of its limit range.']);
        end
    end
    
    if withinLimits
        disp('The final joint configuration is within the robot''s joint limits.');
    else
        disp('The final joint configuration is NOT within the robot''s joint limits.');
    end
end
