%% Set Up Simulation
figure('Position', [100, 100, 1200, 800]); % [left, bottom, width, height]
axis([-10 10 -10 10 -5 15]); % [xmin xmax ymin ymax zmin zmax]
axis equal;
view(3);
campos([30 30 20]);
camtarget([0 0 0]);
camup([0 0 1]);
camva(45);

% Labels and title
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Workspace Setup');

env = SetEnvironment();

%% Initialize the UR3 robot model
UR3 = LinearUR3e(transl(0.1, -1.1, 0.5) * trotz(pi/2));

%% Define Initial Positions for the Gems
initialGemPositions = [
    0.5, -1.3, 0.55;  % Gem 1
    0.5, -1.5, 0.55;  % Gem 2
    0.5, -1.7, 0.55;  % Gem 3
];

% Define the camera position for analysis
cameraPosition = [-0.5, -1.2, 0.6];

% Define exchange positions for sorting by color
exchangePositions.red = [
    -0.2, -1.6, 0.55;  % Position for red gems
];
exchangePositions.green = [
    -0.2, -1.8, 0.55;  % Position for green gems
];

%% Gem Setup
% Create gem objects and place them in the environment
gems = [
    Gem([0.5, -1.5, 0.5], 'large', 'green',UR3)
    Gem([0.5, -1.3, 0.5], 'large', 'red', UR3)
    Gem([0.5, -1.7, 0.5], 'small', 'red', UR3)
];

% Verify that gems are created properly
if isempty(gems)
    error('Gems array is empty. Make sure the gems are properly initialized.');
end

% Initialize UR3 Movement with required parameters
UR3MovementInstance = UR3Movement(UR3, initialGemPositions, cameraPosition, exchangePositions, gems);

%% Execute Sorting Tasks
% Perform sorting tasks using the UR3
UR3MovementInstance.ExecuteTask();

disp('Gem sorting process complete.');

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

% %% Execute Sorting Tasks
% % Perform sorting tasks using both robots
% % First, execute UR3's task to sort by color
% UR3MovementInstance.ExecuteTask();
% 
% % After executing the UR3 movement, place gems at the exchange positions
% for i = 1:length(gems)
%     % Determine the exchange position based on the gem color
%     if strcmp(gems(i).color, 'red')
%         exchangePosition = robotMovement.exchangePositionsRed(1, :); % Update based on gem index if needed
%     elseif strcmp(gems(i).color, 'green')
%         exchangePosition = robotMovement.exchangePositionsGreen(1, :); % Update based on gem index if needed
%     else
%         error('Unknown gem color detected.');
%     end
% 
%     % Move the UR3 to the exchange position for the gem
%     UR3MovementInstance.MoveToPosition(exchangePosition);
% 
%     % After moving, mark the gem as sorted
%     gems(i).isSorted = true; % Mark the gem as sorted
%     pause(0.5);
% end
% 
% % Execute sorting tasks by size using the ABB robot
% robotMovement.ExecuteSortingTask();
% 
% disp('Gem sorting process complete.');


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
robot = LinearUR3e(transl(0.1, -1.1, 0.6) * trotz(pi/2));

% Set the workspace for visualization
axis([-3 2 -3 2 0 2]);
grid on;
%%
% q = [-0.7 0 pi/2 0 0 -pi/2 0];
q = [-0.5 0 pi/2 0 0 -pi/2 0];

robot.model.animate(q);


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

