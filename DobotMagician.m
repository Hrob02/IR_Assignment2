classdef DobotMagician1 < RobotBaseClass
    properties (Access = public)
        % Define the base name for the ply files used for visualization
        plyFileNameStem = 'DobotMagician';
        numSteps = 50; % Number of steps for the animation
    end

    methods
        %% Constructor
        function self = DobotMagician(baseTr)
            if nargin < 1
                baseTr = eye(4); % Default base transform if none is provided
            end
            % Create the model and set the base transformation
            self.CreateModel();
            self.model.base = baseTr;
            % Plot and color the robot using the ply files
            self.PlotAndColourRobot();
        end

        %% Create the robot model
        function CreateModel(self)
           
            link(1) = Link('d',(0.103+0.0362)*2,    'a',0,      'alpha',-pi/2,  'offset',0, 'qlim',[deg2rad(-135),deg2rad(135)]);
            link(2) = Link('d',0,        'a',0.135,  'alpha',0,      'offset',-pi/2, 'qlim',[deg2rad(5),deg2rad(80)]);
            % link(3) = Link('d',0,        'a',0.147,  'alpha',0,      'offset',0, 'qlim',[deg2rad(-5),deg2rad(85)]);
            % link(4) = Link('d',0,        'a',0.06,      'alpha',pi/2,  'offset',-pi/2, 'qlim',[deg2rad(-180),deg2rad(180)]);
            % link(5) = Link('d',-0.05,      'a',0,      'alpha',0,      'offset',pi, 'qlim',[deg2rad(-85),deg2rad(85)]);

          
            % Create a SerialLink object using the defined links
            self.model = SerialLink(link, 'name', self.name);
        end

    end
end
