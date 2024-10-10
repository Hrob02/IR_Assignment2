classdef ABB120 < RobotBaseClass
    properties (Access = public)
        % Define the base name for the ply files used for visualization
        plyFileNameStem = 'ABB120';
        numSteps = 50; % Number of steps for the animation
    end

    methods
        %% Constructor
        function self = ABB120(baseTr)
            if nargin < 1
                baseTr = eye(4); % Default base transform if none is provided
            end
            % Create the model and set the base transformation
            self.CreateModel();
            self.model.base = baseTr * trotx(pi/2) * troty(pi/2);
            % Plot and color the robot using the ply files
            self.PlotAndColourRobot();
        end

        %% Create the robot model
        function CreateModel(self)
           
            % First link as prismatic from the rail system
            link(1) = Link([pi 0 0 pi/2 1]); % PRISMATIC Link

            % Define the D-H parameters for each link based on the given table
            link(2) = Link('d', 0.290, 'a', 0, 'alpha', -pi/2, 'qlim', deg2rad([-360 360]), 'offset', 0);
            link(3) = Link('d', 0, 'a', 0.270, 'alpha', 0, 'qlim', deg2rad([-360 360]), 'offset', -pi/2); % Offset -pi/2 to match DH table
            link(4) = Link('d', 0, 'a', 0.070, 'alpha', -pi/2, 'qlim', deg2rad([-360 360]), 'offset', 0);
            link(5) = Link('d', 0.302, 'a', 0, 'alpha', pi/2, 'qlim', deg2rad([-360 360]), 'offset', 0);
            link(6) = Link('d', 0, 'a', 0, 'alpha', -pi/2, 'qlim', deg2rad([-360 360]), 'offset', 0);
            link(7) = Link('d', 0.072, 'a', 0, 'alpha', 0, 'qlim', deg2rad([-360 360]), 'offset', 0);

             % Add Joint Limits
            link(1).qlim = [-0.8 -0.01];
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-90 90]*pi/180;
            link(4).qlim = [-170 170]*pi/180;
            link(5).qlim = [-360 360]*pi/180;
            link(6).qlim = [-360 360]*pi/180;
            link(7).qlim = [-360 360]*pi/180;

            % Create a SerialLink object using the defined links
            self.model = SerialLink(link, 'name', self.name);
        end

    end
end
