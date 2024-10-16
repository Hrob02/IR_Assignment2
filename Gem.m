classdef Gem < handle
    properties
        position % [x, y, z] position of the gem
        size % 'small' or 'large'
        color % 'red' or 'green'
        meshHandle % Handle for the gem's graphical representation
        isSorted = false; % Status flag to indicate if the gem has been sorted
    end

    methods
        function obj = Gem(position, size, color)
            % Constructor to initialize gem properties
            obj.position = position;
            obj.size = size;
            obj.color = color;
            
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
            
            % Scale the mesh based on size
            scale = 1.0; % Default scale for large gems
            if strcmp(size, 'small')
                scale = 0.5; % Scale factor for small gems
            elseif ~strcmp(size, 'large')
                error('Unsupported gem size: %s', size);
            end
            vertices = vertices * scale;
            
            % Create a graphical representation of the gem
            obj.meshHandle = trisurf(faces, ...
                                     vertices(:, 1) + position(1), ...
                                     vertices(:, 2) + position(2), ...
                                     vertices(:, 3) + position(3), ...
                                     'FaceColor', [1 0 0], 'EdgeColor', 'none');
            % Set color-specific properties
            if strcmp(color, 'green')
                set(obj.meshHandle, 'FaceColor', [0 1 0]);
            end
        end

        function MoveToPosition(obj, newPosition)
            % Method to move the gem to a new position
            translation = newPosition - obj.position; % Calculate the translation vector
            obj.position = newPosition; % Update the gem's position
            % Update the vertices' positions based on the translation
            newVertices = get(obj.meshHandle, 'Vertices') + translation;
            set(obj.meshHandle, 'Vertices', newVertices);
        end

        function DeleteGem(obj)
            % Method to delete the gem's graphical representation
            if isvalid(obj.meshHandle)
                delete(obj.meshHandle);
            end
        end
    end
end
