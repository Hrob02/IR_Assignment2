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

% Define models for the UR3 and ABB robots
UR3Model = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));
ABBModel = ABB120(transl(-1.25, -1.15, 0.5) * trotz(pi/2));
%%

% Step 1: Create an instance of EStopController
eStopController = EStopController();  % Create a shared EStopController instance

% Step 2: Create instances of UR3Movement and ABBMovement with the shared EStopController
ur3Movement = UR3Movement(gems, UR3Model, eStopController);  % Create UR3Movement instance
abbMovement = ABBMovement(gems, ABBModel, eStopController);  % Create ABBMovement instance

% Step 3: Instantiate the GUI and pass the movement instances
app = app1;  % Create an instance of your app
app.initializeAppWithInstances(ur3Movement, abbMovement, eStopController);  % Pass the movement instances

%% Main loop using the instances from the app
for i = 1:length(gems)
    % Execute the movement using the instances stored in the app
    app.UR3MovementInst.ExecuteUR3(i);
    app.ABBMovementInst.ExecuteRobot(i);
end


%%
% Move to a specific Cartesian coordinate (example: x = 0.4, y = -0.3, z = 0.6)
ur3Movement = UR3Movement(gems, UR3Model, eStopController);  % Create UR3Movement instance
ur3Movement.MoveToCartesian(0.3824, -1.069, 0.59);
