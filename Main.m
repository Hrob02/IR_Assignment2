% Create the environment
env = SetEnvironment();


%% 
% Initialize the robot
robot = DobotMagician(transl(0,-1.5,0.5));

%%
robot = LinearABB120();

q = zeros(7);
robot.model.fkine(q);


