classdef PropertyChanger

    properties (Access = public)
	   propertyChanges = []; 
    end
    
    methods (Access = public)

        function this = addPropertyChange(this, propertyChange)
            this.propertyChanges{1, length(this.propertyChanges) + 1} = propertyChange; 
        end

    end

    methods (Static, Access = public)
        
        function target = updateProperties(target, changes, time)
            if (~isempty(changes))
                for i = 1:length(changes)
                    currPropertyChange = changes{i}; 
                    changeTime = currPropertyChange.eventTime; 
                    currPropertyName = currPropertyChange.propertyName; 
                    if ((time >= changeTime) && isprop(target, currPropertyName))
                        target.(currPropertyName) = currPropertyChange.newValue; 
                    end
                end
            end
        end

    end
   
end
