classdef SetEnvironment
    properties
        FloorImage = 'WhiteFloor.jpg';
        WallImage0 = 'Labwall.jpg';
        WallImage1 = 'LabWall1.jpg';
        TableFile = 'tableBrown2.1x1.4x0.5m.ply';
        FireExtinguisherFile = 'fireExtinguisher.ply';
        ManFile = 'personMaleConstruction.ply';
        EstopFile = 'emergencyStopWallMounted.ply';
    end
    
    methods
        function obj = SetEnvironment()
            % Initialize environment
            obj.displayEnvironment();
            obj.placeObjects();
        end
        
        function displayEnvironment(obj)
            % Load images
            img = imread(obj.FloorImage);
            imgwall0 = imread(obj.WallImage0);
            imgwall00 = imrotate(imgwall0, 180);
            imgwall1 = imread(obj.WallImage1);
            imgwall10 = imrotate(imgwall1, -90);

            % Display floor
            surf([-3, -3; 2.5, 2.5], ...
                 [-3, 2.5; -3, 2.5], ...
                 [0.0, 0.0; 0.0, 0.0], ...
                 'CData', img, ...
                 'FaceColor', 'texturemap');
            hold on;

            % Display walls
            surf([-3, -3; 2.5, 2.5], ...
                 [2.5, 2.5; 2.5, 2.5], ...
                 [0.0, 2.5; 0.0, 2.5], ...
                 'CData', imgwall10, ...
                 'FaceColor', 'texturemap');

            surf([2.5, 2.5; 2.5, 2.5], ...
                 [-3, 2.5; -3, 2.5], ...
                 [0.0, 0.0; 2.5, 2.5], ...
                 'CData', imgwall00, ...
                 'FaceColor', 'texturemap');
        end
        
        function placeObjects(obj)
            % Place table
            PlaceObject(obj.TableFile, [-0.5, -1.5, 0]);
            
            % Place fire extinguisher
            PlaceObject(obj.FireExtinguisherFile, [-1.5, 2.4, 0.5]);

            % Place additional objects
            objman = PlaceObject(obj.ManFile, [2.2, 2, 0]);
            vertices = get(objman, 'Vertices');
            position = [2.2, 2, 0]; % Update with actual position if necessary
            centered = vertices - position;
            rotationMatrix = trotz(pi);
            transformed = (rotationMatrix(1:3, 1:3) * centered')';
            set(objman, 'Vertices', transformed + position);

            eobj = PlaceObject(obj.EstopFile, [2, 2.4, 1]);
            vertices = get(eobj, 'Vertices');
            position = [2, 2.4, 1]; % Update with actual position if necessary
            centered = vertices - position;
            rotationMatrix = trotz(pi);
            transformed = (rotationMatrix(1:3, 1:3) * centered')';
            set(eobj, 'Vertices', transformed + position);

             % Place fences
             fencePositions = [-2.25,0; -0.75,0; 0.75,0];
             for i = 1:size(fencePositions, 1)
                 PlaceObject('barrier1.5x0.2x1m.ply', [fencePositions(i,:), 0]);
             end
             
             RotatedFencePositions = [1.5,-0.75; 1.5,-2.25];
             for i = 1:size(RotatedFencePositions)
                 % Assuming placeObject has been used and objects are already in the environment
                 % Replace this with code to fetch the object if necessary
                 obj = PlaceObject('barrier1.5x0.2x1m.ply', [RotatedFencePositions(i,:), 0]);
                 vertices = get(obj, 'Vertices');
                 pos = [RotatedFencePositions(i,:), 0]; % Update with actual position if necessary
                 centered = vertices - pos;
                 rotationMatrix = trotz(pi/2); % Example rotation
                 transformed = (rotationMatrix(1:3, 1:3) * centered')';
                 set(obj, 'Vertices', transformed + pos);
             end
        end
    end
end
