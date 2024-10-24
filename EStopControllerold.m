classdef EStopController < handle
    properties
        eStopEngaged = false; % Shared emergency stop flag
    end
    
    events
        EStopEngaged
        EStopDisengaged
    end
    
    methods
        % Method to engage the emergency stop
        function EngageEStop(obj)
            if ~obj.eStopEngaged
                obj.eStopEngaged = true;
                disp('Emergency stop engaged. All robot movement halted.');
                % Trigger the event
                notify(obj, 'EStopEngaged');
            end
        end
        
        % Method to disengage the emergency stop
        function DisengageEStop(obj)
            if obj.eStopEngaged
                obj.eStopEngaged = false;
                disp('Emergency stop disengaged. Resuming robot movement.');
                % Trigger the event
                notify(obj, 'EStopDisengaged');
            end
        end
    end
end
