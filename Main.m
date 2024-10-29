%% Environment  

% Setup figure and axes
figureHandle = figure('Position', [100, 100, 1200, 800]);
% axis([-10 10 -10 10 -5 15]); % [xmin xmax ymin ymax zmin zmax]
% axis equal;
axis([-3 2.5 -3 2.5 0 2.5]); % Set axis boundaries that match wall and floor sizes
axis off; % Hide axis and grid lines
set(gca, 'Color', 'none'); % Set background to none if necessary
view(3);
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Workspace Setup');


env = SetEnvironment(figureHandle);

%% Initialise

% Create gem objects and place them in the environment
gems = [
    Gem([0.4, -1.2, 0.53], 'small', 'red');
    Gem([0.4, -1.35, 0.53], 'small', 'green');
    Gem([0.4, -1.5, 0.53], 'large', 'red');
    Gem([0.4, -1.65, 0.53], 'small', 'red');
    Gem([0.4, -1.8, 0.53], 'large', 'green'); 
    Gem([0.4, -1.95, 0.53], 'small', 'red'); 
];
%%
% Define models for the UR3 and ABB robots
UR3Model = LinearUR3e(transl(-0.15, -1.1, 0.5) * trotz(pi/2));
ABBModel = ABB120(transl(-1.25, -1.15, 0.5) * trotz(pi/2));
%%
% if isempty(a)
%a = arduino('/dev/tty.usbserial-110','Uno');
% end

% Step 1: Create an instance of EStopController
eStopController = EStopController();  % Create a shared EStopController instance

% Step 2: Create instances of UR3Movement and ABBMovement with the shared EStopController
ur3Movement = UR3Movement(gems, UR3Model, eStopController);%,a);  % Create UR3Movement instance
abbMovement = ABBMovement(gems, ABBModel, eStopController);%,a);  % Create ABBMovement instance

% Step 3: Instantiate the GUI and pass the movement instances
app = app1;  % Create an instance of your app
app.initializeAppWithInstances(ur3Movement, abbMovement, eStopController);  % Pass the movement instances

%% Main loop using the instances from the app
pause(5);

for i = 1:length(gems)
    % Execute the movement using the instances stored in the app
    app.UR3MovementInst.ExecuteUR3(i);
    app.ABBMovementInst.ExecuteRobot(i);
end







