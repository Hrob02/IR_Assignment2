classdef Gem < handle
    properties
        position % [x, y, z] position of the gem
        size % 'small' or 'large'
        color % 'red' or 'green'
        meshHandle % Handle for the gem's graphical representation
        isSorted = false; % Status flag to indicate if the gem has been sorted
        vertices % Store vertices of the gem for manipulation
        updatedPoints;
        endEffectorTransform;
        UR3; % Reference to UR3 object
        pos;
    end

    methods
        function obj = Gem(position, size, color, UR3Model)
            % Constructor to initialize gem properties
            obj.position = position;
            obj.size = size;
            obj.color = color;
            obj.UR3 = UR3Model; % Store the UR3 instance
            obj.pos = zeros(1,6);

            % Calculate the end effector transform using the UR3 instance
            obj.endEffectorTransform;

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

        function attachToEndEffector(obj, endEffectorTransform)
             % Use a temporary variable for clarity
            verticesTemp = obj.vertices;
        
            % Check if vertices are non-empty and have the correct dimensions
            if isempty(verticesTemp) || size(verticesTemp, 2) ~= 3
                error('Vertices are empty or incorrectly shaped. Expected a Nx3 matrix.');
            end
            
            % Calculate the midpoint of the gem's vertices
            midPoint = mean(verticesTemp, 1); % Calculate the midpoint
            % Move the midpoint to the origin
            centeredVertices = verticesTemp - midPoint;

            obj.pos = obj.UR3.model.getpos(); % Example if it returns a structure

            disp(obj.pos);

            obj.endEffectorTransform = obj.UR3.model.fkine(obj.pos);
        
            % Extract the position from the transformation and ensure it's in the right format
            newPosition = endEffectorTransform.T'; % Extract the position vector from the transformation
        
            % Update the gem's position
            obj.position = newPosition; 
            
            % Calculate updated vertices positions using the transformation
            % Apply the transformation to the centered vertices
            obj.updatedPoints = (endEffectorTransform * [centeredVertices, ones(size(centeredVertices, 1), 1)]')';
            obj.meshHandle.Vertices = obj.updatedPoints(:, 1:3); % Update mesh vertices
        end

        function DeleteGem(obj)
            % Method to delete the gem's graphical representation
            if isvalid(obj.meshHandle)
                delete(obj.meshHandle);
            end
        end
    end
end
