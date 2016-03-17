classdef LinearMovement < CanClone

    properties (Access = public)
        Id;
        Direction; 
        Speed; 
        OriginalX; 
        OriginalY; 
    end
    
    methods (Access = public)
        
        function this = LinearMovement(xmlNode)
            if (nargin == 1)
                this.Id = Utils.strToChar(xmlNode.getAttribute('id'));
                this.Direction = Utils.strToInt(xmlNode.getAttribute('direction'));
                this.Speed = Utils.strToInt(xmlNode.getAttribute('speed'));
                this.OriginalX = 0; 
                this.OriginalY = 0; 
            else
                this.Id = '';
                this.Direction = 0;
                this.Speed = 0; 
                this.OriginalX = 0; 
                this.OriginalY = 0; 
            end
        end
        
        function [x, y] = move(this, time)
            angle = LinearMovement.degtorad(this.Direction); 
            distance = floor(this.Speed * time); 
            [displacementX, displacementY] = LinearMovement.pointOnCircle(distance, angle);
            x = this.OriginalX + displacementX; 
            y = this.OriginalY - displacementY; 
        end
        
    end
    
    methods (Static, Access = public)
        
        function normalizedDeg = normalizeAngleDeg(deg)
            normalizedDeg = rem(deg, 360); 
        end

        function rad = degtorad(deg)
            rad = deg * pi/180;
        end
        
        function [x, y] = pointOnCircle(radius, angleInRad)
            x = radius * cos(angleInRad);
            y = radius * sin(angleInRad);
        end
        
    end
    
    
end
