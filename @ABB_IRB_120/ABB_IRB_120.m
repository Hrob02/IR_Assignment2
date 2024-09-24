classdef ABB_IRB_120 < RobotBaseClass
    % New industrial robot arm ABB's IRB_120
    % moutned on linear rail for 7 DOF
    properties (Access = public)
        plyFileNameStem = 'ABB_IRB_120';
    end

    methods
        % constructor
        function obj = ABB_IRB_120(baseTr)
            obj.CreateModel();
            if nargin == 1			
				obj.model.base = obj.model.base.T * baseTr * troty(pi/2);
            end
            obj.PlotAndColourRobot();
        end

        function CreateModel(obj)
            link(1) = Link([pi     0       0       pi/2    1]); % PRISMATIC Link for linear rail
            link(2) = Link('d',0.290,'a',0,'alpha',-90*pi/180);
            link(3) = Link('d',0,'a',0.270,'alpha',0);
            link(4) = Link('d',0,'a',0.070,'alpha',-90*pi/180);
            link(5) = Link('d',0.302,'a',0,'alpha',90*pi/180);
            link(6) = Link('d',0,'a',0,'alpha',-90*pi/180);
            link(7) = Link('d',0.072,'a',0,'alpha',-90*pi/180);

            % Incorporate joint limits
            link(1).qlim = [-0.8 -0.01];
            link(2).qlim = [-165 165]*pi/180;
            link(3).qlim = [-110 110]*pi/180;
            link(4).qlim = [-110 70]*pi/180;
            link(5).qlim = [-160 160]*pi/180;
            link(6).qlim = [-120 120]*pi/180;
            link(7).qlim = [-360 360]*pi/180;

            link(3).offset = -pi/2;
            link(7).offset = pi/2;

            obj.model = SerialLink(link,'name',obj.name);
        end
    end
end

