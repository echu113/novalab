classdef PropertyChange < CanClone

    properties (Access = public)
       id; 
	   propertyName;
       newValue;
       eventTime; 
    end
    
    methods (Access = public)

        function this = PropertyChange(xmlNode)
            if (nargin == 1)
                this.id = Utils.strToChar(xmlNode.getAttribute('id')); 
                this.propertyName = Utils.strToChar(xmlNode.getAttribute('propertyName'));
                this.newValue = Utils.strToInt(xmlNode.getAttribute('newValue')); 
                this.eventTime = Utils.strToDouble(xmlNode.getAttribute('time')); 
            end
        end
        
    end
   
end
