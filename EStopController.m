classdef EStopController < handle
    properties (SetObservable)  % Add the SetObservable attribute for events
        eStopEngaged = false; % Shared emergency stop flag
    end
    
    methods
        % Method to engage the emergency stop
        function EngageEStop(obj)
            obj.eStopEngaged = true;
            disp('Emergency stop engaged. All robot movement halted.');
            % Notify any listeners about the state change
            notify(obj, 'EStopStateChanged');
        end
        
        % Method to disengage the emergency stop
        function DisengageEStop(obj)
            obj.eStopEngaged = false;
            disp('Emergency stop disengaged. Ready to resume robot movement.');
            % Notify any listeners about the state change
            notify(obj, 'EStopStateChanged');
        end
    end
    
    events
        EStopStateChanged;  % Declare an event for e-stop state changes
    end
end
