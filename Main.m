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
    Gem([0.3824, -0.869, 0.51], 'small', 'red'); %% needs unique q values for pick and drop off
    Gem([0.3824, -1.069, 0.51], 'small', 'red');
    Gem([0.3824, -1.269, 0.51], 'small', 'red');
    Gem([0.3824, -1.469, 0.5], 'large', 'green');
    Gem([0.3824, -1.669, 0.51], 'small', 'red');
    Gem([0.3824, -1.869, 0.51], 'small', 'red'); %% needs unique q values for pick and drop off
];


% Verify that gems are created properly
if isempty(gems)
    error('Gems array is empty. Make sure the gems are properly initialized.');
end

% Visualize gems in their initial positions
for i = 1:length(gems)
    gems(i).MoveToPosition(gems(i).position);  % Ensure gems are visualized correctly
end

%% Delete gems
for i = 1:length(gems)
    gems(i).DeleteGem();  % Delete the gem's graphical representation
end

%% UR3 Control
% Main script to run the UR3 and manage gems

% Initialize the UR3 robot model
UR3 = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));

% Define initial positions for the gems
initialGemPositions = [
    0.3824, -1.469, 0.59;  % Gem 1
    % 0., -1.5, 0.55;  % Gem 2
    % 0.5, -1.7, 0.55;  % Gem 3
];

% Define the camera position for analysis 
cameraPosition = [-0.6921, -0.999, 0.6519];

% Define exchange positions for sorting by color
exchangePositions.red = [
    -0.6824, -1.731, 0.59;  % Position for red gems
];
exchangePositions.green = [
    % -0.2, -1.8, 0.55;  % Position for green gems
];

% Initialize UR3 Movement with required parameters
UR3MovementInstance = UR3Movement(UR3, initialGemPositions, cameraPosition, exchangePositions, gems);

% Initial starting position of the LinearUR3e robot
q0 = zeros(1,7); % Initial configuration

% Camera q value for UR3e
q_cam = [-0.2 pi -pi/2 0 0 0 0];  % Camera position configuration

% Define pickup and dropoff configurations
q_pickup = [
    % Pickup for Gem(1) %% need to add its unique
    -0.1 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(2)
    -0.3 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(3)
    -0.5 pi 17*pi/40 0 25*pi/360 -pi/2 0;  % Pickup for Gem(4)
    -0.7 pi 17*pi/40 0 25*pi/360 -pi/2 0   % Pickup for Gem(5)
    -0.8 pi 17*pi/40 0 25*pi/360 -pi/2 0   % Pickup for Gem(6) %% need to change
];

q_dropoff = [
    % Dropoff for Gem(1) %% need to add its unique
    -0.3 0 17*pi/40 0 25*pi/360 -pi/2 0    % Dropoff for Gem(2)
    -0.3 0 17*pi/40 0 25*pi/360 -pi/2 0    % Dropoff for Gem(3)
    -0.5 0 17*pi/40 0 25*pi/360 -pi/2 0;   % Dropoff for Gem(4)
    -0.7 0 17*pi/40 0 25*pi/360 -pi/2 0    % Dropoff for Gem(5)
    -0.8 0 17*pi/40 0 25*pi/360 -pi/2 0    % Dropoff for Gem(6) %% need to change
];



%% Loop through each pickup and dropoff position
for i = 1:length(q_pickup)
    
    % Move to initial position
    UR3MovementInstance.MoveToJointConfiguration(q0);
    pause(1);  % Wait for 2 seconds
    
    % Move to pickup configuration
    UR3MovementInstance.MoveToJointConfiguration(q_pickup(i, :));
    pause(1);  % Wait for 2 seconds
    
    % Move to camera position
    UR3MovementInstance.MoveToJointConfiguration(q_cam);
    pause(1);  % Wait for 2 seconds
    
    % Move to initial position again
    UR3MovementInstance.MoveToJointConfiguration(q0);
    
    
    % Move to dropoff configuration
    UR3MovementInstance.MoveToJointConfiguration(q_dropoff(i, :));
    pause(1);  % Wait for 2 seconds
    
end


%% Robot Control
% Initialize the ABB robot model
robot = ABB120(transl(-1.15, -1.15, 0.5) * trotz(pi/2));

% Define sorting positions for different sizes and colors
sortPositions = {
    [-1.8, -1.2, 0.6]; % Red large
    [-1.8, -1.4, 0.6]; % Red small
    [-1.8, -1.6, 0.6]; % Green large
    [-1.8, -1.8, 0.6]; % Green small
};

% Initialize Robot Movement with required parameters
robotMovement = RobotMovement(robot, sortPositions, gems, true);


% Assuming robotMovement is an instance of RobotMovement
% Define exchange positions for sorting red gems
robotMovement.exchangePositionsRed = [
    0.6421, -1.931, 0.844;  % Position 1 for red gems (initial)
    -0.4421, -1.931, 0.6598;  % Position 2 for red gems (initial)
];

% Define final sort positions
finalPositionRedLarge = [-1.8, -1.2, 0.6];  % Final position for Red large gem
finalPositionRedSmall = [-1.8, -1.4, 0.6];  % Final position for Red small gem

% Move the robot to the initial exchange positions for red gems
disp('Moving to initial position 1 for red gems...');
robotMovement.MoveToPosition(robotMovement.exchangePositionsRed(1, :));
pause(1);

disp('Moving to initial position 2 for red gems...');
robotMovement.MoveToPosition(robotMovement.exchangePositionsRed(2, :));
pause(1);

% Move the robot to the final sorting positions for red gems
disp('Moving to final position for Red large gem...');
robotMovement.MoveToPosition(finalPositionRedLarge);
pause(1);

disp('Moving to final position for Red small gem...');
robotMovement.MoveToPosition(finalPositionRedSmall);
pause(1);

% % Define exchange positions for sorting red and green gems
% robotMovement.exchangePositionsRed = [
%     0.6421, -1.931, 0.844;  % Position 1 for red gems
%     -0.4421, -1.931, 0.6598;  % Position 2 for red gems
% ];
% % robotMovement.exchangePositionsGreen = [
% %     -0.2, -1.8, 0.55;  % Position 1 for green gems
% %     -0.4, -1.8, 0.55;  % Position 2 for green gems
% %     -0.6, -1.8, 0.55;  % Position 3 for green gems
% % ];
% 
% % Set the camera position for analysis
% robotMovement.cameraPlace = cameraPosition;

%% Execute Sorting Tasks
% Perform sorting tasks using both robots
% First, execute UR3's task to sort by color
UR3MovementInstance.ExecuteTask(robotMovement);

for i = 1:length(gems)
    % Determine the exchange position based on the gem color
    if strcmp(gems(i).color, 'red')
        exchangePosition = exchangePositions.red(1, :); % Update based on gem index if needed
    elseif strcmp(gems(i).color, 'green')
        exchangePosition = exchangePositions.green(1, :); % Update based on gem index if needed
    else
        error('Unknown gem color detected.');
    end
    % Place the gem at the determined exchange position
    UR3MovementInstance.PlaceGemAtExchange(robotMovement);
    pause(0.5);
end

% Execute sorting tasks by size using the ABB robot
robotMovement.ExecuteSortingTask();

disp('Gem sorting process complete.');

%% Volume
% create an instance of the PointCloudTest class
pointCloudTester = PointCloudTest(UR3);
% Specify the number of samples you want for the point cloud
numSamples = 100; % You can adjust this number as needed

% Generate the point cloud
pointCloudTester.createPointCloud(numSamples);




% %% WOrk here
% mesh_h = PlaceObject('RedRuby.ply');
% axis equal
% vertices = get(mesh_h,'Vertices');
% 
% 
% transformedVertices = [vertices,ones(size(vertices,1),1)] * transl(0,0,0.1)';
% set(mesh_h,'Vertices',transformedVertices(:,1:3));
% 
% transformedVertices = [vertices,ones(size(vertices,1),1)] * trotx(pi/2)';
% set(mesh_h,'Vertices',transformedVertices(:,1:3));
% 
% 
% mdl_planar3
% hold on
% p3.plot([0,0,0])
% p3.delay = 0;
% 
% axis([-3,3,-3,3,-0.5,8])
% 
% for i = -pi/4:0.01:pi/4
%     p3.animate([i,i,i])
%     tr = p3.fkine([i,i,i]).T * transl(0.5,0,0);
%     transformedVertices = [vertices,ones(size(vertices,1),1)] * tr';
%     set(mesh_h,'Vertices',transformedVertices(:,1:3));
%     drawnow();
%     pause(0.01);
% end

%%

 sortingTable = [-2,-2.05,0.65; -2,-1.45,0.65; -0.5,-2.05,0.55];
             for i = 1:size(sortingTable)
                 Shelves = PlaceObject('bookcaseTwoShelves0.5x0.2x0.5m.ply', [sortingTable(i,:)]);
                 vertices = get(Shelves, 'Vertices');
                 pos = [sortingTable(i,:)]; % Update with actual position if necessary
                 centered = vertices - pos;
                 rotationMatrix = trotx(-pi/2); % Example rotation
                 transformed = (rotationMatrix(1:3, 1:3) * centered')';
                 set(Shelves, 'Vertices', transformed + pos);
             end
%%

% Initialize the robot model
robot1 = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));
%%
% q1 = [-0.5 0 17*pi/40 0 25*pi/360 -pi/2 0]; % drop off for UR3e
 % q1 = [-0.2 pi -pi/2 0 0 0 0]; % Camera q value for UR3e
q1 = [-0.6 pi 17*pi/40 0 25*pi/360 -pi/2 0]; % pick up for gem
robot1.model.animate(q1);

robot1.model.fkine(q1)

% gem position drop off at -0.7 q primatic joint transl(-0.4365,-1.931,0.5533);

% gem position drop off at -0.5 q primatic joint transl(-0.4365,-1.731,0.5533);

%%
% Set the workspace for visualization
axis([-3 2 -3 2 0 2]);
grid on;
%%
% Initialize the ABB robot model
robot = ABB120(trotz(pi/2));

% Set the workspace for visualization
axis([-3 2 -3 2 0 2]);
grid on;

% q = [-0.7 0 pi/2 0 0 -pi/2 0];
% q = [-0.5 0 pi/2 0 0 -pi/2 0];
q = [0.7 0 0 0 0 0 0];

robot1.model.animate(q1);


%%
% Initialize variables
steps = 100;

% Define the start and end brick transformations

t2_start = transl(-0.2, -1.7, 0) * transl(0, 0, 0.19) * rpy2tr(180, 0, 0, 'deg');
t3_start = transl(-0.3, 0.5, 0) * transl(0, 0, 0.19) * rpy2tr(180, 0, 0, 'deg');
t4_start = transl(-0.4, 0.5, 0) * transl(0, 0, 0.19) * rpy2tr(180, 0, 0, 'deg');

t2_end = transl(-0.5, -0.5, 0) * transl(0, 0, 0.04) * rpy2tr(180, 0, 90, 'deg');
t3_end = transl(-0.635, -0.5, 0) * transl(0, 0, 0.04) * rpy2tr(180, 0, 90, 'deg');
t4_end = transl(-0.77, -0.5, 0) * transl(0, 0, 0.04) * rpy2tr(180, 0, 90, 'deg');

% Calculate inverse kinematics for each transformation
q2_start = robot.model.ikcon(t2_start);
q3_start = robot.model.ikcon(t3_start);
q4_start = robot.model.ikcon(t4_start);

q2_end = robot.model.ikcon(t2_end);
q3_end = robot.model.ikcon(t3_end);
q4_end = robot.model.ikcon(t4_end);

% Generate the trajectories between the positions
path1 = jtraj(q2_start, q2_end, steps);
path2 = jtraj(q3_start, q3_end, steps);
path3 = jtraj(q4_start, q4_end, steps);

% Define the paths for easier looping
paths = {path1, path2, path3};

% Total number of paths
totalPaths = 3;

% Loop through the trajectories to animate the robot
for n = 1:totalPaths
    % Display status of the task
    fprintf('Moving to brick location %d...\n', n);

    % Animate the robot moving through the trajectory
    for i = 1:steps
        robot.model.animate(paths{n}(i, :));
        drawnow;
    end
    
    % Display completion of the task
    fprintf('Brick %d moved.\n', n);
end

% Display completion status
fprintf('Task completed. All bricks have been moved.\n');


%%

% Initialize the robot model
robot = LinearUR3e(trotz(pi/2));

%%

% Define the desired joint configurations
q0 = [-0.7 0 -pi/2 0 0 -pi/2 0];
q1 = [-0.7 0 pi/2 0 0 -pi/2 0];  % First configuration
q2 = [-0.5 0 pi/2 0 0 -pi/2 0];  % Second configuration


% Create the UR3Movement object (assuming you already have UR3Model and other inputs)
movementObj = UR3Movement(UR3, initialGemPositions, cameraPosition, exchangePositions, gems);


% Move the robot to q0
movementObj.MoveToJointConfiguration(q0);

% Move the robot to q1
movementObj.MoveToJointConfiguration(q1);

% Move the robot to q2
movementObj.MoveToJointConfiguration(q2);
%%

% Define the target position (0.5, -1.3, 0.55)
targetPosition = [0.5, -1.3, 0.55];

% Move the UR3 robot to the target position
movementObj.MoveToPosition(targetPosition);

robot.model.getpos()

%%
% Define the desired joint configurations (6 DOF, not 7)
q0 = [-0.7 0 -pi/2 0 0 -pi/2 0];  % First configuration
q1 = [-0.7 0 pi/2 0 0 -pi/2 0];   % Second configuration
q2 = [-0.5 0 pi/2 0 0 -pi/2 0];   % Third configuration

% Example initialization (adapt to your specific setup)
UR3Model = UR3();  % Assuming UR3() is a valid model
initialGemPositions = [0, 0, 0];  % Placeholder, modify based on actual gem positions
cameraPosition = [0.5, -0.8, 0.6];  % Example camera position
exchangePositions.red = [0.5, -0.5, 0.2];  % Example position
exchangePositions.green = [0.6, -0.6, 0.2];  % Example position
gems = [];  % Placeholder, add gem data if needed

% Create the UR3Movement object
movementObj = UR3Movement(UR3, initialGemPositions, cameraPosition, exchangePositions, gems);

% Move the robot to q0
movementObj.MoveToJointConfiguration(q0);

pause(1);

movementObj.UR3.model.fkine(q0)

% Move the robot to q1
movementObj.MoveToJointConfiguration(q1);

pause(1);

movementObj.UR3.model.fkine(q1)

% Move the robot to q2
movementObj.MoveToJointConfiguration(q2);

pause(1);

movementObj.UR3.model.fkine(q2)



