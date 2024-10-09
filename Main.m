% Set the size of the figure window
figure('Position', [100, 100, 1200, 800]); % [left, bottom, width, height]

% Set axis properties
axis([-10 10 -10 10 -5 15]); % [xmin xmax ymin ymax zmin zmax]
axis equal; % Ensure the scale is equal in all directions

% Set the camera view angle and position
view(3); % 3D view
campos([30 30 20]); % Set camera position [x, y, z]
camtarget([0 0 0]); % Set the target point [x, y, z]
camup([0 0 1]); % Set the up direction [x, y, z]
camva(45); % Set the camera view angle

% Set lighting and shading
lighting gouraud; % Smooth lighting
shading interp; % Interpolated shading
camlight('headlight'); % Set a light source at the camera

% Set labels for the axes
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Workspace Setup'); % Title for the plot

% Create the environment
env = SetEnvironment();


%% 
% Initialize the DOBOT
Dobot = DobotMagician(transl(0,-1.5,0.5));

%%
% Create an instance of the LinearABB120 robot with the given transformation
robotModel = LinearABB120(transl(-1.15,-1.15,0.5)*trotz(pi/2));

% Set step size in radians and chunk size
stepRads = deg2rad(5);  % Adjust step size as needed (e.g., 5 degrees)
chunkSize = 5000;       % Adjust chunk size based on memory and accuracy needs

% Instantiate the PointCloud class
pointCloudObj = PointCloud(robotModel, stepRads, chunkSize);

% Generate and visualize the point cloud of the robot workspace
pointCloud = pointCloudObj.createPointCloud();

