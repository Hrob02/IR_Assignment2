try
    % Close all figures and clear any existing handles
    clf;
    close all;
    clear all;
    bdclose all;

    % Create an instance of the LinearABB120 robot with the given transformation
    robot = LinearABB120();

    % Validate that the robot model is not empty
    if isempty(robot.model)
        error('Failed to initialize the LinearABB120 robot model.');
    end

    % Set step size in radians and chunk size
    stepRads = deg2rad(60);  % Adjust step size as needed
    chunkSize = 1000;        % Adjust chunk size based on memory and accuracy needs

    % Create an instance of the LinearRobotPointCloud class
    robotPointCloud = LinearRobotPointCloud(robot, stepRads, chunkSize);

    % Generate the point cloud of the robot workspace
    robotPointCloud = robotPointCloud.createPointCloud();

    % % Calculate and display the volume of the workspace
    % volume = robotPointCloud.calculateVolume();
    
catch ME
    % If there's an error related to the robot or its handles, display a message
    disp(['Error: ' ME.message]);
    disp('Please check if the robot model is initialized correctly or if there are conflicting handles.');
end
