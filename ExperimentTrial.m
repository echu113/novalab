classdef ExperimentTrial
    
    properties (Access = public)
        Id; 
        trialTargets; 
        Background;
        Duration; 
    end
    
    methods (Access = public)
        
        function obj = ExperimentTrial(xmlNode, targets, movements, propertyChanges, backgrounds)
            obj.Id = Utils.strToChar(xmlNode.getAttribute('id')); 

            trialTargetIds = Utils.strToArrayPreserveElemStrings(xmlNode.getAttribute('trialTargets'));
            if (length(trialTargetIds) >= 1)
                obj.trialTargets = cell(1, length(trialTargetIds)); 
                
                for i = 1:length(trialTargetIds)
                    currTargetId = trialTargetIds{i};
                    if (targets.isKey(currTargetId))
                        currTarget = targets(currTargetId); 
                        currTarget.X = Utils.strToInt(xmlNode.getAttribute(strcat(currTargetId, '.x')));
                        currTarget.Y = Utils.strToInt(xmlNode.getAttribute(strcat(currTargetId, '.y')));
                        
                        % add movement to current target
                        targetMovementId = Utils.strToChar(xmlNode.getAttribute(strcat(currTargetId, '.movement')));
                        if (movements.isKey(targetMovementId) && ~isempty(movements(targetMovementId)))
                            targetMovement = movements(targetMovementId).clone(); 
                        else
                            targetMovement = LinearMovement(); 
                        end
                        
                        targetMovement.OriginalX = currTarget.X; 
                        targetMovement.OriginalY = currTarget.Y; 
                        
                        currTarget.Movement = targetMovement; 

                        % add property changes to current target
                        propertyChangeIds = Utils.strToArrayPreserveElemStrings(xmlNode.getAttribute(strcat(currTargetId, '.propertyChanges'))); 
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
            
            obj.Background = backgrounds(Utils.strToChar(xmlNode.getAttribute('background'))).clone(); 
            backgroundId = obj.Background.Id; 

            % hack - check existence, should implement generically
            backgroundMovementId = Utils.strToChar(xmlNode.getAttribute(strcat(backgroundId, '.movement')));
            if (movements.isKey(backgroundMovementId) && ~isempty(movements(backgroundMovementId)))
                backgroundMovement = movements(backgroundMovementId).clone(); 
            else
                backgroundMovement = LinearMovement(); 
            end
            obj.Background.Movement = backgroundMovement;
            
            % add property changes to current target
            backgroundPropertyChangeIds = Utils.strToArrayPreserveElemStrings(xmlNode.getAttribute(strcat(backgroundId, '.propertyChanges'))); 
            if (~isempty(backgroundPropertyChangeIds))
                for j = 1:length(backgroundPropertyChangeIds)
                    currChangeId = backgroundPropertyChangeIds{j};
                    if (propertyChanges.isKey(currChangeId) && ~isempty(propertyChanges(currChangeId)))
                        currChange = propertyChanges(currChangeId).clone(); 
                        obj.Background = obj.Background.addPropertyChange(currChange); 
                    end
                end
            end
            
            
            obj.Duration = Utils.strToDouble(xmlNode.getAttribute('duration')); 
        end
        
        function obj = runTrial(obj, window)
            % Enable alpha blending for anti-aliasing
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            % Query the frame duration
            ifi = Screen('GetFlipInterval', window);

            % Sync us and get a time stamp
            waitframes = 1;

            % Maximum priority level
            topPriorityLevel = MaxPriority(window);
            Priority(topPriorityLevel);

            vbl = Screen('Flip', window);
            time = 0;
            
            ListenChar(2); 

            while (time <= obj.Duration)
                
                obj.Background = obj.Background.drawOnScreen(window); % hack to init proper parameters, should move to "initialization"
                obj.Background = obj.Background.updateState(time); 
                obj.Background = obj.Background.move(time); 

                if (length(obj.trialTargets) >= 1)
                    for i = 1:length(obj.trialTargets)
                        currTarget = obj.trialTargets{1, i}; 
                        
                        currTarget.drawOnScreen(window); 
                        currTarget = currTarget.updateState(time); 
                        currTarget = currTarget.move(time);
                        obj.trialTargets{1, i} = currTarget; 
                    end
                end

                % Flip to the screen
                vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                % Increment the time
                time = time + ifi;
            end

            
            % todo write to data file properly
            [ch, ~] = GetChar();            
            if (~isempty(ch))
                disp('key pressed!');
                disp(ch); 
            end
            ListenChar(0); 

        end
            
    end
    
end
