classdef Sapphire < handle
    properties (Constant)
        maxHeight = 10;  % Max height for plotting the workspace
    end
    
    properties
        gemCount = 1;           % Number of gems (formerly brickCount)
        gemModel = {};          % Cell array to hold gem models (formerly brickModel)
        workspaceDimensions;    % Dimensions of the workspace
    end
    
    methods
        %% Constructor
        function self = Sapphire(gemCount, positions)
            if nargin > 0
                self.gemCount = gemCount;  % Set the number of gems
            end
            
            % Initialize workspace dimensions
            self.workspaceDimensions = [-2, 2, -2, 2, 0, self.maxHeight];

            % Create and position the required number of gems
            for i = 1:self.gemCount
                % Set the gem's position using the provided positions
                if nargin > 1 && i <= numel(positions)
                    basePose = transl(positions{i});  % Set position based on input
                else
                    basePose = transl(0, 0, 0);  % Default to origin
                end

                % Create the gem model
                self.gemModel{i} = self.GetGemModel(['gem', num2str(i)]);
                self.gemModel{i}.base = basePose;

                % Plot 3D model
                plot3d(self.gemModel{i}, 0, 'workspace', self.workspaceDimensions, 'view', [-30, 30], 'delay', 0, 'noarrow', 'nowrist');
                hold on;
            end

            axis equal
            if isempty(findobj(get(gca, 'Children'), 'Type', 'Light'))
                camlight;
            end 
        end
    end
    
    methods (Static)
        %% GetGemModel
        function model = GetGemModel(name)
            if nargin < 1
                name = 'Gem';  % Default name
            end
            [faceData, vertexData] = plyread('BlueSapphire.ply', 'tri');  % Use the BlueSapphire.ply file
            link1 = Link('alpha', 0, 'a', 0, 'd', 0, 'offset', 0);
            model = SerialLink(link1, 'name', name);
            
            % Assign face and vertex data to the model
            model.faces = {[], faceData};
            model.points = {[], vertexData};
        end
    end    
end
