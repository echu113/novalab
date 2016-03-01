classdef CanClone

    methods (Access = public)
    
        % Make a copy of a handle object.
        function new = clone(this)
            % Instantiate new object of the same class.
            new = feval(class(this));
 
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                try 
                    new.(p{i}) = this.(p{i});
                catch exception
                    continue; 
                end
            end
        end
    
    end
    
end
