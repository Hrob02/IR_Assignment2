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

<<<<<<< HEAD

%% 
% Initialize the robot
robot = DobotMagician(transl(0,-1.5,0.5));
=======
% Initialize the DOBOT
Dobot = DobotMagician(transl(0,-1.5,0.5));

% Initialise the second robot
% robot2 = ABB_IRB_120(transl(-0.5,-1.5,0.5)*trotx(pi/2)*trotz(pi/2));
>>>>>>> 2d70e8d258e95a71f399a483f51af1f1d8a7a0c4

%%
robot = LinearABB120();

q = zeros(7);
robot.model.fkine(q);


