classdef LinearRobotPointCloud
    properties
        robot           % Robot model
        stepRads        % Step size in radians for joint movement
        chunkSize       % Chunk size for managing memory allocation
        pointCloudData  % Store the generated point cloud data
    end
    
    methods
        % Constructor to initialize the LinearRobotPointCloud object
        function obj = LinearRobotPointCloud(robotModel, stepRads, chunkSize)
            if nargin > 0
                obj.robot = robotModel;
                obj.stepRads = stepRads;
                obj.chunkSize = chunkSize;
            else
                error('Robot model, step size, and chunk size must be provided.');
            end
        end

        % Method to generate the point cloud of the robot workspace
        function obj = createPointCloud(obj)
            hold on;

            % Validate that the robot model is properly initialized
            if isempty(obj.robot.model)
                error('The robot model is not properly initialized or has been deleted.');
            end

            % Access joint limits directly from the SerialLink model
            qlim = obj.robot.model.qlim;

            % Preallocate point cloud array
            totalPoints = obj.chunkSize * 100;  % Estimate the total number of points
            pointCloud = zeros(totalPoints, 3);
            counter = 1;

            % Loop through joint configurations and collect points
            for q1 = qlim(1,1):0.1:qlim(1,2)  % Larger increment for prismatic joint
                for q2 = qlim(2,1):obj.stepRads:qlim(2,2)
                    for q3 = qlim(3,1):obj.stepRads:qlim(3,2)
                        for q4 = qlim(4,1):obj.stepRads:qlim(4,2)
                            for q5 = qlim(5,1):obj.stepRads:qlim(5,2)
                                q = [q1, q2, q3, q4, q5, 0, 0];  % Simplified q vector
                                try
                                    tr = obj.robot.model.fkine(q).T; % Get the transformation matrix
                                catch ME
                                    warning('Error calculating fkine for q = %s: %s', mat2str(q), ME.message);
                                    continue;
                                end
                                pointCloud(counter, :) = tr(1:3, 4)'; % Store the position
                                counter = counter + 1;

                                if counter > size(pointCloud, 1)
                                    % Expand pointCloud array if necessary
                                    pointCloud = [pointCloud; zeros(obj.chunkSize, 3)];
                                end
                            end
                        end
                    end
                end
            end

            % Trim any unused preallocated rows
            pointCloud = pointCloud(1:counter-1, :);

            % Store point cloud in the object's property
            obj.pointCloudData = pointCloud;

            % Plot the final point cloud
            figure;
            plot3(pointCloud(:,1), pointCloud(:,2), pointCloud(:,3), 'r.');
            title('Workspace Point Cloud');
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            grid on;
            axis equal;
        end

        % Method to calculate and display the volume of the workspace
        function volume = calculateVolume(obj)
            % Ensure pointCloudData is not empty
            if isempty(obj.pointCloudData)
                error('Point cloud data is empty. Generate the point cloud first using createPointCloud().');
            end

            pointCloud = obj.pointCloudData;

            % Remove any rows in pointCloud that are all zeros (if applicable)
            pointCloud = pointCloud(any(pointCloud, 2), :);

            % Calculate the convex hull of the point cloud
            [~, V] = convhull(pointCloud(:,1), pointCloud(:,2), pointCloud(:,3));

            % Display the volume
            fprintf('The volume of the workspace is approximately %.4f cubic units.\n', V);
            volume = V;
        end
    end
end
