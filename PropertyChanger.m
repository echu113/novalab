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
        
        function target = updateProperties(target, changes, time, fixating)
            if (~isempty(changes))
                for i = 1:length(changes)
                    currPropertyChange = changes{i}; 
                    changeTime = currPropertyChange.eventTime; 
                    currPropertyName = currPropertyChange.propertyName;
                    duringFixation = currPropertyChange.duringFixation;
                    if (isempty(duringFixation))
                        duringFixation = 0; 
                    end
                    if ((time >= changeTime) && isprop(target, currPropertyName))
                        if ((logical(duringFixation) && logical(fixating)) || (~logical(duringFixation) && ~logical(fixating)))
                            if (~currPropertyChange.used)
                                target.(currPropertyName) = currPropertyChange.newValue;
                                currPropertyChange.used = true; 
                            end
                        end
                    end
                end
            end
        end

    end
   
end
