classdef LinearABBIRB120 < RobotBaseClass
    properties(Access = public)   
        plyFileNameStem = 'LinearABBIRB120';
        numSteps = 50; % Number of steps for the animation
    end
    
    methods
        %% Constructor
        function self = LinearABBIRB120(baseTr)
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
            link(2) = Link('d',0.15185,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',90);
            link(3) = Link('d',0,'a',-0.24355,'alpha',0,'qlim',deg2rad([-360 360]), 'offset',0);
            link(4) = Link('d',0,'a',-0.2132,'alpha',0,'qlim',deg2rad([-360 360]), 'offset',0);
            link(5) = Link('d',0.13105,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            link(6) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
            link(7) = Link('d',0.0921,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);

            % % Gripper Links
            % link(8) = Link('d',0,'a',0,'alpha',0,'qlim',deg2rad([-360, 360]), 'offset', 0); % Base link of gripper


            % Add Joint Limits
            link(1).qlim = [-0.8 -0.01];
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-90 90]*pi/180;
            link(4).qlim = [-170 170]*pi/180;
            link(5).qlim = [-360 360]*pi/180;
            link(6).qlim = [-360 360]*pi/180;
            link(7).qlim = [-360 360]*pi/180;

            % Add Offset
            link(3).offset = -pi/2;
            link(5).offset = -pi/2;

            self.model = SerialLink(link, 'name', self.name);
        end

    end
end
