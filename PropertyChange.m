classdef PropertyChange < CanClone

    properties (Access = public)
       id; 
	   propertyName;
       newValue;
       duringFixation; 
       eventTime; 
       used = false; 
    end
    
    methods (Access = public)

        function this = PropertyChange(xmlNode)
            if (nargin == 1)
                this.id = Utils.strToChar(xmlNode.getAttribute('id')); 
                this.propertyName = Utils.strToChar(xmlNode.getAttribute('propertyName'));
                this.newValue = Utils.strToInt(xmlNode.getAttribute('newValue')); 
                this.duringFixation = Utils.strToInt(xmlNode.getAttribute('duringFixation'));
                if (isempty(this.duringFixation))
                    this.duringFixation = 0; 
                end
                this.eventTime = Utils.strToDouble(xmlNode.getAttribute('time')); 
            end
        end
        
    end
   
end
