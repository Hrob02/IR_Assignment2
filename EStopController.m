classdef EStopController < handle
    properties
        eStopEngaged = false; % Shared emergency stop flag
    end
    
    methods
        % Method to engage the emergency stop
        function EngageEStop(obj)
            obj.eStopEngaged = true;
            disp('Emergency stop engaged. All robot movement halted.');
        end
        
        % Method to disengage the emergency stop
        function DisengageEStop(obj)
            obj.eStopEngaged = false;
            disp('Emergency stop disengaged. Resuming robot movement.');
        end
    end
end