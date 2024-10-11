classdef Sapphire < handle
    properties (Constant)
        maxHeight = 10;  % Max height for plotting the workspace
    end
    
    properties
        gemCount = 1;           % Number of gems
        gemPatch = {};          % Cell array to hold gem patches
        workspaceDimensions;    % Dimensions of the workspace
        gemPosition = {};       % Store position transforms of each gem
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
                    basePose = positions{i};  % Set position based on input
                else
                    basePose = eye(4);  % Default to identity matrix (origin)
                end

                % Store the base position of each gem
                self.gemPosition{i} = basePose;
                
                % Create and plot the gem model using the custom method
                self.gemPatch{i} = self.CreateAndPlotGem('BlueSapphire.ply', basePose);

                % Hold on to allow multiple patches to be plotted
                hold on;
            end

            % Set axis properties
            axis equal;
        end
    end
    
    methods (Static)
        %% CreateAndPlotGem
        function gemPatch = CreateAndPlotGem(plyFileName, basePose)
            % Read the .ply file data
            [faceData, vertexData, plyData] = plyread(plyFileName, 'tri');

            % Check if color data is available and normalize
            if isfield(plyData.vertex, 'red')
                vertexColors = [plyData.vertex.red, plyData.vertex.green, plyData.vertex.blue] / 255;
            else
                vertexColors = repmat([0, 0, 1], size(vertexData, 1), 1);  % Default color (blue)
            end

            % Apply the base transformation to the vertex data
            homogeneousVertices = [vertexData, ones(size(vertexData, 1), 1)];  % Add the homogeneous coordinate
            transformedVertices = (basePose * homogeneousVertices')';  % Apply transformation
            transformedVertices = transformedVertices(:, 1:3);  % Remove homogeneous coordinate

            % Plot the .ply file using patch
            gemPatch = patch('Faces', faceData, 'Vertices', transformedVertices(:, 1:3), ...
                             'FaceVertexCData', vertexColors, ...
                             'FaceColor', 'interp', ...
                             'EdgeColor', 'none');
                             
            % Add light source only if no lights exist
            if isempty(findall(gcf, 'Type', 'light'))
                camlight;
            end

            % Set up view properties
            axis equal;
        end
    end    
end
