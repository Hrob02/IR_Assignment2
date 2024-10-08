classdef LinearABB120 < RobotBaseClass
    properties(Access = public)   
        plyFileNameStem = 'LinearABB120';
        numSteps = 50; % Number of steps for the animation
    end
    
    methods
        %% Constructor
        function self = LinearABB120(baseTr)
            if nargin < 1			
                baseTr = eye(4);				
            end
            self.CreateModel();
            self.model.base = baseTr * trotx(pi/2) * troty(pi/2);
            self.PlotAndColourRobot();
        end

        %% Create the robot model
        function CreateModel(self)
            % First link as prismatic from the rail system
            link(1) = Link([pi 0 0 pi/2 1]); % PRISMATIC Link
           
            % Add UR3e links
            link(2) = Link('d',0.07185,'a',0,'alpha',0,'qlim',deg2rad([-360 360]), 'offset',0);
            link(3) = Link('d',0.3,'a',0 ,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',pi/2);
            link(4) = Link('d',0 ,'a',0.265,'alpha',pi,'qlim',deg2rad([-360 360]), 'offset',0);
            link(5) = Link('d',0,'a',0.07,'alpha',-pi/2,'qlim',deg2rad([-360 360]),'offset', 0); %floating cube should always be zero 
            link(6) = Link('d',0.14,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset',0);
            link(7) = Link('d',0.17,'a',0,'alpha',pi/2,'qlim',deg2rad([-360,360]), 'offset', pi/2);

            % % Gripper Links
            % link(8) = Link('d',0,'a',0,'alpha',0,'qlim',deg2rad([-360, 360]), 'offset', 0); % Base link of gripper


            % Add Joint Limits
            link(1).qlim = [-0.8 -0.01];
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-90 90]*pi/180;
            link(4).qlim = [-170 170]*pi/180;
            % link(5).qlim = [-360 360]*pi/180;
            % link(6).qlim = [-360 360]*pi/180;
            % link(7).qlim = [-360 360]*pi/180;
            % 
            % % Add Offset
            % link(3).offset = 0;
            % link(5).offset = -pi/2;

            self.model = SerialLink(link, 'name', self.name);
        end

    end
end
