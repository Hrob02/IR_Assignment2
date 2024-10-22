% Set Up Simulation
% Set up the figure window and workspace
figure('Position', [100, 100, 1200, 800]); % [left, bottom, width, height]
axis([-10 10 -10 10 -5 15]); % [xmin xmax ymin ymax zmin zmax]
axis equal;
view(3);
campos([30 30 20]);
camtarget([0 0 0]);
camup([0 0 1]);
camva(45);

% Lighting and shading
lighting gouraud;
shading interp;
camlight('headlight');

% Labels and title
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Workspace Setup');

% Create the environment
env = SetEnvironment();

%% Gem Setup
% Create gem objects and place them in the environment
gems = [
    Gem([0.3824, -1.069, 0.51], 'small', 'red');
    Gem([0.3824, -1.269, 0.51], 'large', 'red');
    Gem([0.3824, -1.469, 0.5], 'large', 'green');
    Gem([0.3824, -1.669, 0.51], 'small', 'red');
    Gem([0.3824, -1.869, 0.51], 'small', 'red'); 
    Gem([0.3824, -2.029, 0.51], 'small', 'red'); 
];

Gem([-1.829,  -1.25, 0.56], 'small', 'red'); 
Gem([-1.829,  -1.45, 0.58], 'large', 'red'); 
Gem([-1.829,  -1.65, 0.54], 'small', 'green'); 
Gem([-1.829,  -1.85, 0.54], 'large', 'green'); 

Gem([-0.6791,  -1.65, 0.51], 'large', 'green');
Gem([-0.6791,  -1.85, 0.51], 'large', 'red');

% Visualize gems in their initial positions
for i = 1:length(gems)
    gems(i).MoveToPosition(gems(i).position);  % Ensure gems are visualized correctly
end

%% Delete gems
for i = 1:length(gems)
    gems(i).DeleteGem();  % Delete the gem's graphical representation
end


%% UR3 Control
% Initialize the UR3 robot model
UR3 = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));

% Initialize UR3 Movement
UR3MovementInstance = UR3Movement(UR3);

%% Pick and analyze gems

% Initial starting position of the LinearUR3e robot
q0 = zeros(1,7); % Initial configuration

% Camera q value for UR3e
q_cam = [-0.2 pi -pi/2 0 0 0 0];  % Camera position configuration

% Define pickup configurations for the gems
q_pickup = [
    -0.1 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(1)
    -0.3 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(2)
    -0.5 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(3)
    -0.7 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(4)
    -0.64 0 -17*pi/40 0 -25*pi/360 pi/2 0; % Pickup for Gem(5)
    -0.8 0 -17*pi/40 0 -25*pi/360 pi/2 0;  % Pickup for Gem(6)
];

% Define drop-off configurations for green and red gems
q_dropoff_green = [-0.5 0 17*pi/40 0 25*pi/360 -pi/2 0];  % Dropoff for green gems
q_dropoff_red = [-0.7 0 17*pi/40 0 25*pi/360 -pi/2 0];    % Dropoff for red gems

% Loop through each gem, pick it, move to the camera, and analyze it
for i = 1:length(gems)
    % Move to initial position
    UR3MovementInstance.MoveToJointConfiguration(q0);
    pause(1);  % Wait for 1 second
    
    % Move to the pickup configuration for Gem(i)
    disp(['Picking gem: ', num2str(i)]);
    
    UR3MovementInstance.MoveToJointConfiguration(q_pickup(i, :));
    pause(1);  % Wait for 1 second
    
    % Move to camera position and analyze the gem
    UR3MovementInstance.MoveToJointConfiguration(q_cam);

    pause(2);
    
    % Check the gem's color and decide the drop-off location
    if strcmp(gems(i).color, 'green')
        disp(['Gem color: ', gems(i).color]);
        disp('Moving to Green drop-off location.');
        UR3MovementInstance.MoveToJointConfiguration(q_dropoff_green);
    elseif strcmp(gems(i).color, 'red')
        disp(['Gem color: ', gems(i).color]);
        disp('Moving to Red drop-off location.');
        UR3MovementInstance.MoveToJointConfiguration(q_dropoff_red);
    else
        disp('Unknown gem color.');
    end
    
    pause(1);  % Wait for 1 second
end

UR3MovementInstance.MoveToJointConfiguration(q0);

%% Robot Control
% Initialize the ABB robot model
robot = ABB120(transl(-1.25, -1.15, 0.5) * trotz(pi/2));

% Initialize Robot Movement with required parameters
robotMovement = RobotMovement(robot);

%% Initial configurations
q0 = zeros(1,7); % Initial configuration for ABB120
q_transition = [-0.5 pi/2 0 0 0 0 0]; % Transition joint configuration
q_cam = [-0.02 0 pi/2 -3*pi/10 pi/2 pi/2 0]; % Camera position configuration

% Define pickup locations for the robot (based on the previous drop-off points)
q_pickup_green = [-0.5 0 pi/2 -7*pi/20 0 7*pi/20 0];  % Pickup for green gems
q_pickup_red = [-0.7 0 pi/2 -7*pi/20 0 7*pi/20 0];    % Pickup for red gems

% Automatically generate q_pickup array based on gem colors
q_pickup = zeros(length(gems), 7);  % Pre-allocate for pickup configurations

for i = 1:length(gems)
    if strcmp(gems(i).color, 'red')
        q_pickup(i, :) = q_pickup_red;    % Assign red pickup location
    elseif strcmp(gems(i).color, 'green')
        q_pickup(i, :) = q_pickup_green;  % Assign green pickup location
    end
end

% Define drop-off configurations for each combination of color and size
q_dropoff = [
   -0.1 pi pi/2 -9*pi/20 0 9*pi/20 0;  % Dropoff for red small gems
   -0.3 pi pi/2 -9*pi/20 0 9*pi/20 0;  % Dropoff for red large gems
   -0.5 pi pi/2 -9*pi/20 0 9*pi/20 0;  % Dropoff for green small gems
   -0.7 pi pi/2 -9*pi/20 0 9*pi/20 0;  % Dropoff for green large gems
];


%% Loop through each gem, pick it, analyze it, and sort it
for i = 1:length(gems)
    % Move to initial position
    robotMovement.MoveToJointConfiguration(q0);
    pause(1);  % Wait for 1 second
    
    % Move to pickup configuration for Gem(i) (assigned dynamically based on color)
    robotMovement.MoveToJointConfiguration(q_pickup(i, :));
    pause(1);  % Wait for 1 second
    
    % Display the size and color of the gem
    disp(['Picking gem ', num2str(i)]);
    % disp(['Gem color: ', gems(i).color]);
    % disp(['Gem size: ', gems(i).size]);

    % Move to camera position and analyze the gem
    robotMovement.MoveToJointConfiguration(q_cam);
    pause(2);  % Wait for 2 seconds for analysis
    

    % Sort the gem based on color and size and move to the appropriate drop-off
    if strcmp(gems(i).color, 'red')
        if strcmp(gems(i).size, 'small')
            disp(['Gem color: ', gems(i).color]);
            disp(['Gem size: ', gems(i).size]);
            disp('Moving to Small Red drop-off location.');
            robotMovement.MoveToJointConfiguration(q_transition);
            robotMovement.MoveToJointConfiguration(q_dropoff(1, :));  % Red small
        elseif strcmp(gems(i).size, 'large')
            disp(['Gem color: ', gems(i).color]);
            disp(['Gem size: ', gems(i).size]);
            disp('Moving to Large Red drop-off location.');
            robotMovement.MoveToJointConfiguration(q_transition);
            robotMovement.MoveToJointConfiguration(q_dropoff(2, :));  % Red large
        end
    elseif strcmp(gems(i).color, 'green')
        if strcmp(gems(i).size, 'small')
            disp(['Gem color: ', gems(i).color]);
            disp(['Gem size: ', gems(i).size]);
            disp('Moving to Small Green drop-off location.');
            robotMovement.MoveToJointConfiguration(q_transition);
            robotMovement.MoveToJointConfiguration(q_dropoff(3, :));  % Green small
        elseif strcmp(gems(i).size, 'large')
            disp(['Gem color: ', gems(i).color]);
            disp(['Gem size: ', gems(i).size]);
            disp('Moving to large green drop-off location.');
            robotMovement.MoveToJointConfiguration(q_transition);
            robotMovement.MoveToJointConfiguration(q_dropoff(4, :));  % Green large
        end
    else
        disp('Unknown gem color or size.');
    end
    
    pause(1);  % Wait for 1 second after dropping off the gem
end


%% Volume
% create an instance of the PointCloudTest class
pointCloudTester = PointCloudTest(UR3);
% Specify the number of samples you want for the point cloud
numSamples = 100; % You can adjust this number as needed

% Generate the point cloud
pointCloudTester.createPointCloud(numSamples);



%%

% Initialize the robot model
robot1 = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));

%%
% Set the workspace for visualization
axis([-3 2 -3 2 0 2]);
grid on;


% q1 = [-0.5 0 17*pi/40 0 25*pi/360 -pi/2 0]; % drop off for UR3e
 % q1 = [-0.2 pi -pi/2 0 0 0 0]; % Camera q value for UR3e

 %%
q1 = [-0.7 0 pi/2 -7*pi/20 0 7*pi/20 0]; % pick up for gem
robot.model.animate(q1);

robot.model.fkine(q1)

% gem position drop off at -0.7 q primatic joint transl(-0.4365,-1.931,0.5533);

% gem position drop off at -0.5 q primatic joint transl(-0.4365,-1.731,0.5533);






