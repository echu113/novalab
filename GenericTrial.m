classdef GenericTrial < ExperimentTrial

    properties (Constant, Access = public)
        TRIAL_TYPE = 'generic'; 
    end
    
    methods (Access = public)
        
        function this = GenericTrial(nodeMap, targets, movements, propertyChanges, backgrounds)
            this@ExperimentTrial(nodeMap, targets, movements, propertyChanges, backgrounds); 
        end
            
    end
    
end
