%% Set Up Simulation
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
    Gem([0.36, -1, 0.5], 'small', 'red');
    Gem([0.5, -1.5, 0.5], 'large', 'green');
    Gem([0.4292, -1.7, 0.5], 'small', 'red');
];

% Verify that gems are created properly
if isempty(gems)
    error('Gems array is empty. Make sure the gems are properly initialized.');
end

%% UR3 Control
% Main script to run the UR3 and manage gems

% Initialize the UR3 robot model
UR3 = LinearUR3e(transl(0.1, -1.1, 0.5) * trotz(pi/2));

% Define initial positions for the gems
initialGemPositions = [
    0.36, -1, 0.6;  % Gem 1
    0.5, -1.5, 0.5;  % Gem 2
    0.4708, -1.7, 0.5;  % Gem 3
];

% Define the camera position for analysis
cameraPosition = [-0.2, -1.2, 0.55];

% Define exchange positions for sorting by color
exchangePositions.red = [
    -0.2, -1.6, 0.55;  % Position for red gems
];
exchangePositions.green = [
    -0.2, -1.8, 0.55;  % Position for green gems
];

% Initialize UR3 Movement with required parameters
UR3Movement = UR3Movement(UR3, initialGemPositions, cameraPosition, exchangePositions, gems);


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

% Define exchange positions for sorting red and green gems
robotMovement.exchangePositionsRed = [
    -0.2, -1.6, 0.55;  % Position 1 for red gems
    -0.4, -1.6, 0.55;  % Position 2 for red gems
    -0.6, -1.6, 0.55;  % Position 3 for red gems
];
robotMovement.exchangePositionsGreen = [
    -0.2, -1.8, 0.55;  % Position 1 for green gems
    -0.4, -1.8, 0.55;  % Position 2 for green gems
    -0.6, -1.8, 0.55;  % Position 3 for green gems
];

% Set the camera position for analysis
robotMovement.cameraPlace = cameraPosition;

%% Execute Sorting Tasks
% Perform sorting tasks using both robots
% First, execute UR3's task to sort by color
UR3Movement.ExecuteTask(robotMovement);

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
    UR3Movement.PlaceGemAtExchange(robotMovement);
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
% Initialize the robot model
robot = LinearUR3e() ;

% Define the initial and next joint configurations
q_initial = zeros(1,7);         % Initial pose (all zeros)
q_next = [0 pi/2 0 0 0 0 0];      % Next pose (move to this configuration)

% Set the workspace for visualization
axis([-2 2 -2 2 0 2]);
grid on;

% Define the number of steps for smooth animation
steps = 50;

% Generate a trajectory between the initial and next joint configuration
qMatrix = jtraj(q_initial, q_next, steps);

% Loop through the trajectory and manually update robot's joint transforms
for i = 1:steps
    % Get the forward kinematics for the current joint configuration
    tr = robot.model.fkine(qMatrix(i, :));
    
    % Visualize the robot by transforming the links based on joint angles
    robot.model.animate(qMatrix(i, :));  % Update the robot's joint angles
    
    pause(0.05);  % Pause for smooth animation
end



