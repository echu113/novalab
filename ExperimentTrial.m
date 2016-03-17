classdef ExperimentTrial
    
    properties (Access = public)
        Id; 
        trialTargets;
        fixationTarget; 
        fixationDuration;  
        Background;
        trialDuration; 
    end
    
    properties (Access = protected)
        ifi; 
        waitframes;
        vbl; 
    end
    
    methods (Access = public)
        
        function obj = ExperimentTrial(nodeMap, targets, movements, propertyChanges, backgrounds)
            if (nargin == 5)
            
                obj.Id = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'id')); 

                trialTargetIds = Utils.strToArrayPreserveElemStrings(Utils.getValueFromMap(nodeMap, 'trialTargets'));
                if (length(trialTargetIds) >= 1)
                    obj.trialTargets = cell(1, length(trialTargetIds)); 
                    
                    for i = 1:length(trialTargetIds)
                        currTargetId = trialTargetIds{i};
                        if (targets.isKey(currTargetId))
                            currTarget = targets(currTargetId); 
                            currTarget.X = Utils.strToInt(Utils.getValueFromMap(nodeMap, strcat(currTargetId, '.x')));
                            currTarget.Y = Utils.strToInt(Utils.getValueFromMap(nodeMap, strcat(currTargetId, '.y')));
                            
                            % add movement to current target
                            targetMovementId = Utils.strToChar(Utils.getValueFromMap(nodeMap, strcat(currTargetId, '.movement')));
                            if (movements.isKey(targetMovementId) && ~isempty(movements(targetMovementId)))
                                targetMovement = movements(targetMovementId).clone(); 
                            else
                                targetMovement = LinearMovement(); 
                            end
                            
                            targetMovement.OriginalX = currTarget.X; 
                            targetMovement.OriginalY = currTarget.Y; 
                            
                            currTarget.Movement = targetMovement; 

                            % add property changes to current target
                            propertyChangeIds = Utils.strToArrayPreserveElemStrings(Utils.getValueFromMap(nodeMap, strcat(currTargetId, '.propertyChanges'))); 
                            if (~isempty(propertyChangeIds))
                                for j = 1:length(propertyChangeIds)
                                    currPropertyChangeId = propertyChangeIds{j};
                                    if (propertyChanges.isKey(currPropertyChangeId) && ~isempty(propertyChanges(currPropertyChangeId)))
                                        currPropertyChange = propertyChanges(currPropertyChangeId).clone(); 
                                        currTarget = currTarget.addPropertyChange(currPropertyChange); 
                                    end
                                end
                            end

                            obj.trialTargets{1, i} = currTarget; 
                        end 
                    end 
                end
                

                % TODO*** get rid of duplicate code between initializing background & targets
                
                obj.Background = backgrounds(Utils.strToChar(Utils.getValueFromMap(nodeMap, 'background'))).clone(); 
                backgroundId = obj.Background.Id; 

                % hack - check existence, should implement generically
                backgroundMovementId = Utils.strToChar(Utils.getValueFromMap(nodeMap, strcat(backgroundId, '.movement')));
                if (movements.isKey(backgroundMovementId) && ~isempty(movements(backgroundMovementId)))
                    backgroundMovement = movements(backgroundMovementId).clone(); 
                else
                    backgroundMovement = LinearMovement(); 
                end
                obj.Background.Movement = backgroundMovement;
                
                % add property changes to current target
                backgroundPropertyChangeIds = Utils.strToArrayPreserveElemStrings(Utils.getValueFromMap(nodeMap, strcat(backgroundId, '.propertyChanges'))); 
                if (~isempty(backgroundPropertyChangeIds))
                    for j = 1:length(backgroundPropertyChangeIds)
                        currChangeId = backgroundPropertyChangeIds{j};
                        if (propertyChanges.isKey(currChangeId) && ~isempty(propertyChanges(currChangeId)))
                            currChange = propertyChanges(currChangeId).clone(); 
                            obj.Background = obj.Background.addPropertyChange(currChange); 
                        end
                    end
                end
                

                % FIX THE DUPLICATE CODE

                fixationTargetId = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'fixationTarget')); 
                if (~isempty(fixationTargetId))
                    fixationTarget = Utils.getValueFromMap(targets, fixationTargetId); 
                    if (~isempty(fixationTarget))
                        fixationTarget.X = Utils.strToInt(Utils.getValueFromMap(nodeMap, strcat(fixationTargetId, '.x')));
                        fixationTarget.Y = Utils.strToInt(Utils.getValueFromMap(nodeMap, strcat(fixationTargetId, '.y')));

                        fixationTargetPropertyChangeIds = Utils.strToArrayPreserveElemStrings(Utils.getValueFromMap(nodeMap, strcat(fixationTargetId, '.propertyChanges'))); 
                        if (~isempty(fixationTargetPropertyChangeIds))
                            for j = 1:length(fixationTargetPropertyChangeIds)
                                currFixTargetChangeId = fixationTargetPropertyChangeIds{j};
                                if (propertyChanges.isKey(currFixTargetChangeId) && ~isempty(propertyChanges(currFixTargetChangeId)))
                                    currFixTargetChange = propertyChanges(currFixTargetChangeId).clone(); 
                                    fixationTarget = fixationTarget.addPropertyChange(currFixTargetChange); 
                                end
                            end
                        end

                        obj.fixationTarget = fixationTarget;
                    end
                end


                obj.fixationDuration = Utils.strToDouble(Utils.getValueFromMap(nodeMap, 'fixationDuration')); 
                if (isnan(obj.fixationDuration))
                    obj.fixationDuration = 0; 
                end
                obj.trialDuration = Utils.strToDouble(Utils.getValueFromMap(nodeMap, 'trialDuration')); 
            
            end
            
        end
        
        function this = prepareScreen(this, window)
            % Enable alpha blending for anti-aliasing
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            % Query the frame duration
            this.ifi = Screen('GetFlipInterval', window);

            % Sync us and get a time stamp
            this.waitframes = 1;

            % Maximum priority level
            topPriorityLevel = MaxPriority(window);
            Priority(topPriorityLevel);

            this.vbl = Screen('Flip', window);
        end

        function this = startTrial(this, window)

            time = 0;
            
            while (true)

                this.Background = this.Background.drawOnScreen(window); % hack to init proper parameters, should move to "initialization"
                this.Background = this.Background.updateState(time, 0); 
                this.Background = this.Background.move(time); 

                if (length(this.trialTargets) >= 1)
                    for i = 1:length(this.trialTargets)
                        currTarget = this.trialTargets{1, i}; 

                        if (time <= this.trialDuration)

                            currTarget.drawOnScreen(window); 
                            currTarget = currTarget.updateState(time, 0); 
                            currTarget = currTarget.move(time);
                            this.trialTargets{1, i} = currTarget; 
                        else
                            break; 
                        end
                        
                    end
                end

                this = this.flipScreen(window); 

                if (time > this.trialDuration)
                    currTarget = currTarget.updateState(time, 0); 
                    currTarget.drawOnScreen(window); 
                    this = this.flipScreen(window); 
                    break; 
                end

                % Increment the time
                time = time + this.ifi;
            end

        end

        function this = flipScreen(this, window)
            % Flip to the screen
            this.vbl  = Screen('Flip', window, this.vbl + (this.waitframes - 0.5) * this.ifi);
        end


        function this = fixate(this, window)
            if (~isempty(this.fixationTarget) && this.fixationDuration > 0)
                time = 0; 
                while (time <= this.fixationDuration)
                    this.fixationTarget = this.fixationTarget.updateState(time, 1); 
                    this.fixationTarget.drawOnScreen(window); 
                    this = this.flipScreen(window);
                    time = time + this.ifi;
                end
            end
        end

        function this = runTrial(this, window)
            this = this.prepareScreen(window); 
            this = this.fixate(window); 
            this = this.startTrial(window); 
        end
        
            
    end
    
end
