classdef Background < CanClone & Target

    properties (Constant)
        XML_TAG_BACKGROUND_TEXTURE = 'noiseTextureBackground'; 
    end
    
    properties (Access = public)
        Id;  
        Color; 
        NoiseColor; 
        Density; 
        NoiseRate;
    end
    
    properties (Access = private)
        noiseTexture; 
    end
    
    methods (Access = public)
        
        function this = Background(xmlNode)
            if (nargin == 1)
                this.Id = Utils.strToChar(xmlNode.getAttribute('id')); 
                this.NoiseColor = Utils.strToArray(xmlNode.getAttribute('noiseColor'));
                this.Density = Utils.strToInt(xmlNode.getAttribute('density'));
                this.NoiseRate = Utils.strToDouble(xmlNode.getAttribute('noiseRate'));
            end
            this.X = nan; 
            this.Y = nan; 
        end
        
        function this = drawOnScreen(this, window)
            
            % Get the size of the on screen window in pixels
            [screenXpixels, screenYpixels] = Screen('WindowSize', window);                

            % hack to init proper parameters, should move to a sepearate method for "initialization"
            if (isnan(this.X) || isnan(this.X))
                this.X = -1 * screenXpixels; 
                this.Y = -1 * screenYpixels;     
                this.Movement.OriginalX = this.X; 
                this.Movement.OriginalY = this.Y; 
            end

            if (logical(this.visibility))

                if (isempty(this.noiseTexture))
                    % Construct noise texture
                    density = this.Density * 3; 
                    [x, ~] = meshgrid(-density:1:density, -density:1:density);
                    [s1, s2] = size(x);
                    pd = makedist('bino');
                    pd.p = this.NoiseRate;
                    noise = random(pd, round(s1), round(s2));
                    this.noiseTexture = Screen('MakeTexture', window, noise);
                end

                noiseRect = [this.X, this.Y, this.X + 3*screenXpixels, this.Y + 3*screenYpixels]; 

                % lay down noise background
                Screen('DrawTextures', window, this.noiseTexture, [], noiseRect, [], [], [], this.NoiseColor);

            end

        end 
            
    end

end