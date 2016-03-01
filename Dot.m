classdef Dot < CanClone & Target
    
    properties (Constant)
        XML_TAG_TARGET_DOT = 'dot'; 
    end
    
    properties (Access = private)
        MoverInstance; 
    end
    
    properties (Access = public)
        Id; 
        Radius; 
        Color; 
    end
    
    methods (Access = public)
        
        function obj = Dot(xmlNode)
            if (nargin == 1)
                obj.Id = Utils.strToChar(xmlNode.getAttribute('id')); 
                obj.Radius = Utils.strToInt(xmlNode.getAttribute('radius')); 
                obj.Color = Utils.strToArray(xmlNode.getAttribute('color')); 
            end
        end
        
        function obj = drawOnScreen(obj, window)
        	if (logical(obj.visibility))
            	Screen('DrawDots', window, [obj.X obj.Y], obj.Radius, obj.Color, [], 1); 
        	end
        end 
            
    end
    
end
