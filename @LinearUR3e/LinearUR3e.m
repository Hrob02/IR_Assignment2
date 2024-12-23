classdef LinearUR3e < RobotBaseClass
    %% LinearUR3e UR3e on a non-standard linear rail created by a student
    properties(Access = public)              
        plyFileNameStem = 'LinearUR3e';
       
    end
    
    methods
%% Define robot Function 
        function self = LinearUR3e(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = transl(0,0,0);				
            end
            self.model.base = self.model.base.T * baseTr * trotx(pi/2) * troty(pi/2);
            
            self.PlotAndColourRobot();         
        end

%% Create the robot model
        function CreateModel(self)   
            % Create the UR3e model mounted on a linear rail
            link(1) = Link([pi     0       0       pi/2    1]); % PRISMATIC Link
            %link(2) = Link([0      0.1599  0       -pi/2   0]);
            %link(3) = Link([0      0.1357  0.425   -pi     0]);
            %link(4) = Link([0      0.1197  0.39243 pi      0]);
            %link(5) = Link([0      0.093   0       -pi/2   0]);
            %link(6) = Link([0      0.093   0       -pi/2	0]);
            %link(7) = Link([0      0       0       0       0]);

            % use UR3e links
            link(2) = Link('d',0.15185,'a',0,'alpha',pi/2);
            link(3) = Link('d',0,'a',-0.24355,'alpha',0);
            link(4) = Link('d',0,'a',-0.2132,'alpha',0);
            link(5) = Link('d',0.13105,'a',0,'alpha',pi/2);
            link(6) = Link('d',0.08535,'a',0,'alpha',-pi/2);
            link(7) = Link('d',	0.17,'a',0,'alpha',0);
            
            % Incorporate joint limits
            link(1).qlim = [-0.8 0];
            link(2).qlim = [-360 360]*pi/180;
            link(3).qlim = [-90 90]*pi/180;
            link(4).qlim = [-170 170]*pi/180;
            link(5).qlim = [-360 360]*pi/180;
            link(6).qlim = [-360 360]*pi/180;
            link(7).qlim = [-360 360]*pi/180;
        
            link(3).offset = -pi/2;
            link(5).offset = -pi/2;
            
            self.model = SerialLink(link,'name',self.name);
        end
     
    end
end