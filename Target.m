classdef Target < CanClone

    properties (Access = public)
    	PropertyChanger; 
        Movement; 
        X;
        Y;
        visibility = 1;
    end
    
    methods (Access = public)
        
        function this = Target()
            this.PropertyChanger = PropertyChanger; 
            this.Movement = LinearMovement; 
            this.X = 0; 
            this.Y = 0; 
        end
        
        function this = move(this, time)
            [newX, newY] = this.Movement.move(time); 
            this.X = newX;
            this.Y = newY; 
        end

        function this = updateState(this, time)
            this = this.PropertyChanger.updateProperties(this, this.PropertyChanger.propertyChanges, time); 
        end

        function this = addPropertyChange(this, propertyChange)
        	this.PropertyChanger = this.PropertyChanger.addPropertyChange(propertyChange); 
        end
 
    end
   
end
