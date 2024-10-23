classdef Gem < handle
    properties
        position % [x, y, z] position of the gem
        size % 'small' or 'large'
        color % 'red' or 'green'
        meshHandle % Handle for the gem's graphical representation
        isSorted; % Status flag to indicate if the gem has been sorted
        vertices; % Store vertices of the gem for manipulation
        %endEffectorTransform;
        pos;
    end

    methods
        function obj = Gem(position, size, color)
            % Constructor to initialize gem properties
            obj.position = position;
            obj.size = size;
            obj.color = color;
            obj.pos = [];
            obj.isSorted = false;

            % Calculate the end effector transform using the UR3 instance
            %obj.endEffectorTransform = eye(4);

            % Load the appropriate 3D mesh based on color
            meshFile = '';
            if strcmp(color, 'red')
                meshFile = 'RedRuby.ply';
            elseif strcmp(color, 'green')
                meshFile = 'GreenEmerald.ply';
            else
                error('Unsupported gem color: %s', color);
            end
            
            [faces, vertices, ~] = plyread(meshFile, 'tri');
            obj.vertices = vertices; % Store original vertices

            % Scale the mesh based on size
            scale = 1.0; % Default scale for large gems
            if strcmp(size, 'small')
                scale = 0.5; % Scale factor for small gems
            elseif ~strcmp(size, 'large')
                error('Unsupported gem size: %s', size);
            end
            
            obj.vertices = obj.vertices * scale;

            % Create a graphical representation of the gem
            obj.meshHandle = trisurf(faces, ...
                                     obj.vertices(:, 1) + position(1), ...
                                     obj.vertices(:, 2) + position(2), ...
                                     obj.vertices(:, 3) + position(3), ...
                                     'FaceColor', [1 0 0], 'EdgeColor', 'none');
            % Set color-specific properties
            if strcmp(color, 'green')
                set(obj.meshHandle, 'FaceColor', [0 1 0]);
            end
        end

        function attachToEndEffector(obj, endEffectorTr)
            % Use a temporary variable for clarity
            verticesTemp = obj.vertices;
        
            VertCount = size(verticesTemp, 1);
            
            % Calculate the midpoint of the gem's vertices
            midPoint = mean(verticesTemp, 1); % Calculate the midpoint
            GemVerts = verticesTemp - repmat(midPoint, VertCount, 1); % Center the vertices
        
            % Define the new position based on the end effector's transformation
            newPosition = endEffectorTr * transl(0, 0, 0);
            
            % Calculate updated vertices positions using the transformation
            % Apply the transformation to the centered vertices
            transformedPoints = (newPosition * [GemVerts, ones(VertCount, 1)]')';
            
            % Extracting only the x, y, z coordinates
            updatedPoints = transformedPoints(:, 1:3);
            
            % Update mesh vertices if meshHandle is valid

            obj.meshHandle.Vertices = updatedPoints; % Update mesh vertices

            drawnow();
        end
    end
end
