%% Environment  

% Setup figure and axes
figureHandle = figure('Position', [100, 100, 1200, 800]);
axis([-10 10 -10 10 -5 15]); % [xmin xmax ymin ymax zmin zmax]
axis equal;
view(3);
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Workspace Setup');

env = SetEnvironment(figureHandle);

%% Initialise

% Create gem objects and place them in the environment
gems = [
    Gem([0.3824, -1.069, 0.5], 'small', 'green');
    Gem([0.3824, -1.269, 0.5], 'large', 'red');
    Gem([0.3824, -1.469, 0.5], 'large', 'green');
    Gem([0.3824, -1.669, 0.5], 'small', 'red');
    Gem([0.3824, -1.869, 0.5], 'large', 'red'); 
    Gem([0.3824, -2.029, 0.5], 'small', 'red'); 
];

% Flag Initialization
UR3Finished = false;  % Flag to synchronize UR3 and ABB robots

% Create an instance of EStopController
eStopController = EStopController();

% Initialize the UR3 robot model
UR3 = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));
robot = ABB120(transl(-1.25, -1.15, 0.5) * trotz(pi/2));

%% Create movement instances

UR3MovementInst = UR3Movement(gems, UR3, eStopController);
ABBMovementInst = ABBMovement(gems, robot, eStopController);


%% Main loop

for i = 1:length(gems)
    UR3MovementInst.ExecuteUR3(i);
    ABBMovementInst.ExecuteRobot(i);
end



