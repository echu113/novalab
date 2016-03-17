classdef EyeSoccerTrial < ExperimentTrial

    properties (Constant, Access = public)
        TRIAL_TYPE = 'eyeSoccer'; 
    end
    
    methods (Access = public)
        
        function this = EyeSoccerTrial(nodeMap, targets, movements, propertyChanges, backgrounds)
    		
    		newMap = containers.Map; 
    		newMap('id') = Utils.getValueFromMap(nodeMap, 'id'); 
    		newMap('type') = Utils.getValueFromMap(nodeMap, 'type'); 

			fixPosition = Utils.strToArray(Utils.getValueFromMap(nodeMap, 'fixPosition')); 
			fixPositionVariance = Utils.strToInt(Utils.getValueFromMap(nodeMap, 'fixPositionVariance'));
			isPursuit = logical(Utils.strToInt(Utils.getValueFromMap(nodeMap, 'isPursuit')));

			ball = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'ball'));
			goal = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'goal')); 
			newMap('trialTargets') = ['[', ball, ' ', goal, ']'];

			ballX = fixPosition(1) + (randi(fixPositionVariance) - (fixPositionVariance/2)); 
			ballY = fixPosition(2) + (randi(fixPositionVariance) - (fixPositionVariance/2)); 
			newMap(strcat(ball, '.x')) = num2str(ballX); 
			newMap(strcat(ball, '.y')) = num2str(ballY); 

			% pick the movement to use from the list to have
			% access it in the list of movements
			% figure out how far to place the goal in order to end up at the distance given trial duration and relative hitting positions
			% apply the movement to either ball or goal given either pursuit or fixation trial
			possibleMovements = Utils.strToArrayPreserveElemStrings(Utils.getValueFromMap(nodeMap, 'possibleMovements')); 
			movementId = possibleMovements{randi(length(possibleMovements))};
			movement = Utils.getValueFromMap(movements, movementId); 

			trialDuration = Utils.strToDouble(Utils.getValueFromMap(nodeMap, 'trialDuration')); 

			if (~isempty(movement))

				endingDistance = Utils.strToDouble(Utils.getValueFromMap(nodeMap, 'endingDistance'));
				possibleHitPositions = Utils.strToArray(Utils.getValueFromMap(nodeMap, 'possibleHitPositions')); 
				hitPosition = possibleHitPositions(randi(length(possibleHitPositions))); 

	            backgroundId = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'background')); 
	            newMap('background') = backgroundId; 
	            newMap(strcat(backgroundId, '.movement')) = movementId; 
					
				distanceTraveled = movement.Speed * trialDuration; 
				totalDistance = distanceTraveled + endingDistance;  

				ballGoalAngle = 0; 
                                
                ballPropertyChanges = []; 
                
				if (isPursuit)
					newMap(strcat(ball, '.movement')) = movementId;
					ballGoalAngle = LinearMovement.normalizeAngleDeg(movement.Direction); 
					
					turnRedPropertyChange = PropertyChange; 
					turnRedPropertyChange.id = 'turnRed';
					turnRedPropertyChange.propertyName = 'Color'; 
					turnRedPropertyChange.newValue = [1 0 0]; 
					turnRedPropertyChange.duringFixation = 1; 
					turnRedPropertyChange.eventTime = 0; 
					propertyChanges(turnRedPropertyChange.id) = turnRedPropertyChange; 

					turnWhitePropertyChange = PropertyChange; 
					turnWhitePropertyChange.id = 'turnWhite';
					turnWhitePropertyChange.propertyName = 'Color'; 
					turnWhitePropertyChange.newValue = [1 1 1]; 
					turnWhitePropertyChange.duringFixation = 1; 
					turnWhitePropertyChange.eventTime = Utils.strToDouble(Utils.getValueFromMap(nodeMap, 'fixationDuration')) - 0.1;  
					propertyChanges(turnWhitePropertyChange.id) = turnWhitePropertyChange; 

                    ballPropertyChanges = [turnRedPropertyChange.id];
                    ballPropertyChanges = [ballPropertyChanges, ' ', turnWhitePropertyChange.id]

%                     
% 					newMap(strcat(ball, '.propertyChanges')) = ['[', , ']']; 
% 					newMap(strcat(ball, '.propertyChanges')) = ['[', , ']']; 

				else
					newMap(strcat(goal, '.movement')) = movementId; 
					ballGoalAngle = LinearMovement.normalizeAngleDeg(movement.Direction + 180); 
				end

				[displacementX, displacementY] = LinearMovement.pointOnCircle(totalDistance, LinearMovement.degtorad(ballGoalAngle));
				if (ballGoalAngle <= 90 || ballGoalAngle >= 270)
					newMap(strcat(goal, '.x')) = num2str(ballX + displacementX); 
					newMap(strcat(goal, '.y')) = num2str(ballY - displacementY - hitPosition); 
		        else
		            goalTarget = targets(goal); 
					newMap(strcat(goal, '.x')) = num2str(ballX + displacementX - goalTarget.Width); 
					newMap(strcat(goal, '.y')) = num2str(ballY - displacementY - hitPosition); 
				end

			else
				error('no movement defined for eye soccer trial'); 
			end 

			trialEndPropertyChange = PropertyChange; 
			trialEndPropertyChange.id = 'eye_soccer_auto_hide_everything';
			trialEndPropertyChange.propertyName = 'visibility'; 
			trialEndPropertyChange.newValue = 0; 
			trialEndPropertyChange.eventTime = trialDuration; 

 			propertyChanges(trialEndPropertyChange.id) = trialEndPropertyChange; 

            if (~isempty(ballPropertyChanges))
                ballPropertyChanges = [ballPropertyChanges, ' ', trialEndPropertyChange.id]; 
            else
                ballPropertyChanges = trialEndPropertyChange.id; 
            end
            
			newMap(strcat(ball, '.propertyChanges')) = ['[', ballPropertyChanges, ']']; 
			newMap(strcat(goal, '.propertyChanges')) = ['[', trialEndPropertyChange.id, ']']; 
			newMap(strcat(backgroundId, '.propertyChanges')) = ['[', trialEndPropertyChange.id, ']']; 

            newMap('trialDuration') = Utils.getValueFromMap(nodeMap, 'trialDuration'); 

      		fixationtargetId = Utils.strToChar(Utils.getValueFromMap(nodeMap, 'fixationTarget'));
      		newMap('fixationTarget') = fixationtargetId; % assume fixationTarget is one of 3 elements defined, no need to explicitly add in x & y
      		newMap('fixationDuration') = Utils.getValueFromMap(nodeMap, 'fixationDuration');

			this@ExperimentTrial(newMap, targets, movements, propertyChanges, backgrounds); 
            
        end
            
    end
    
end
