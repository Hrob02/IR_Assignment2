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

%% Animation between different q values using jtraj (need to change for collision avoidance)

% Create an instance of the ABB120 robot
robot = ABB120(transl(-1.15,-1.15,0.5)*trotz(pi/2));

% Define the desired joint configuration
q = [-0.4 0 pi/2 0 0 0 0];  % Example joint configuration

robot.model.animate(q);

% Create an instance of the RobotMovement class
robotMovement = RobotMovement(robot);
robotMovement.ExecuteSortingTask();

% Define initial and final joint configurations
q_initial = zeros(1, 7);
q_pick = [0, 0, pi/2, 0, 0, 0, 0];
q_drop = [0, pi, pi/2, 0, 0, 0, 0];

% Perform the movements using the class methods
robotMovement.MoveToConfiguration(q_initial, q_pick);
robotMovement.MoveToConfiguration(q_pick, q_drop);

fprintf('Task completed.\n');


%% Plotting gems to workspace 

% Define positions for each gem (homogeneous transforms)
positions = {transl(0.1, 0.2, 0.1), transl(0.4, 0.2, 0.1), transl(0.7, 0.2, 0.1)};

% Create an instance of the Emerald class with the positions specified
emeraldGems = Emerald(1, positions(2));

% Create an instance of the Ruby class with the positions specified
rubyGems = Ruby(1, positions(3));


%% WOrk here
mesh_h = PlaceObject('RedRuby.ply');
axis equal
vertices = get(mesh_h,'Vertices');


transformedVertices = [vertices,ones(size(vertices,1),1)] * transl(0,0,0.1)';
set(mesh_h,'Vertices',transformedVertices(:,1:3));

transformedVertices = [vertices,ones(size(vertices,1),1)] * trotx(pi/2)';
set(mesh_h,'Vertices',transformedVertices(:,1:3));


mdl_planar3
hold on
p3.plot([0,0,0])
p3.delay = 0;

axis([-3,3,-3,3,-0.5,8])

for i = -pi/4:0.01:pi/4
    p3.animate([i,i,i])
    tr = p3.fkine([i,i,i]).T * transl(0.5,0,0);
    transformedVertices = [vertices,ones(size(vertices,1),1)] * tr';
    set(mesh_h,'Vertices',transformedVertices(:,1:3));
    drawnow();
    pause(0.01);
end
