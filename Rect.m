classdef Rect < CanClone & Target
    
    properties (Constant)
        XML_TAG_TARGET_RECT = 'rect'; 
    end
    
    properties (Access = public)
        Id; 
        Height; 
        Width; 
        Color;
    end
    
    methods (Access = public)
        
        function obj = Rect(xmlNode)
            if (nargin == 1)      
                obj.Id = Utils.strToChar(xmlNode.getAttribute('id')); 
                obj.Height = Utils.strToInt(xmlNode.getAttribute('height'));
                obj.Width = Utils.strToInt(xmlNode.getAttribute('width')); 
                obj.Color = Utils.strToArray(xmlNode.getAttribute('color')); 
            end
        end
        
        function obj = drawOnScreen(obj, window)
            if (logical(obj.visibility))
                rect = [obj.X obj.Y obj.X+obj.Width obj.Y+obj.Height];
                Screen('FillRect', window, obj.Color, rect);
            end
        end
            
    end
    
end
