classdef Experiment
    
    properties (Access = public)
        id; 
        dummyMode; 
        fullScreen;
        screenCoord; % ignored if fullScreen = true;
    end
    
    methods (Access = public)
        
        function this = Experiment(xmlNode)
            if (nargin == 1)      
                this.id = Utils.strToChar(xmlNode.getAttribute('id')); 
                this.dummyMode = Utils.strToInt(xmlNode.getAttribute('dummyMode'));
                this.fullScreen = Utils.strToInt(xmlNode.getAttribute('fullScreen')); 
                this.screenCoord = Utils.strToArray(xmlNode.getAttribute('screenCoord')); 
            end
        end
                    
    end
    
end
