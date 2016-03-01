classdef XmlParser
    
    properties (Constant)
        XML_TAG_EXPERIMENT = 'experiment'; 
        XML_TAG_TARGET = 'target'; 
        XML_TAG_MOVEMENT = 'movement' 
        XML_TAG_PROPERTY_CHANGE = 'propertyChange'; 
        XML_TAG_BACKGROUND = 'background'; 
        XML_TAG_TRIAL = 'trial'; 
        XML_TAG_TRIAL_ORDER = 'trialOrder'; 
    end
    
    properties (Access = public)
    	Experiment; % single experiment exist at once, ignore the rest
        Targets; 
        Movements; 
        PropertyChanges; 
        Backgrounds; 
        Trials; 
        TrialOrder; 
    end

    methods (Access = public)
        
        function obj = XmlParser(experimentXML)
            document = xmlread(experimentXML); 
            rootElements = document.getElementsByTagName(XmlParser.XML_TAG_EXPERIMENT);
            if (rootElements.getLength >= 0)
                % use first experiment element, ignore the rest
                experimentNode = rootElements.item(0); 
            	obj.Experiment = XmlParser.initializeExperiment(experimentNode); 
                
                targetNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TARGET); 
                obj.Targets = XmlParser.initializeTargets(targetNodes); 
                
                movementNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_MOVEMENT); 
                obj.Movements = XmlParser.initializeMovements(movementNodes); 

                propertyChangeNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_PROPERTY_CHANGE); 
                obj.PropertyChanges = XmlParser.initializePropertyChanges(propertyChangeNodes); 

                backgroundNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_BACKGROUND);
                obj.Backgrounds = XmlParser.initializeBackgrounds(backgroundNodes); 
                
                trialNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TRIAL); 
                obj.Trials = XmlParser.initializeTrials(trialNodes, obj.Targets, obj.Movements, obj.PropertyChanges, obj.Backgrounds); 
                
                trialOrderNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TRIAL_ORDER);
                obj.TrialOrder = XmlParser.initializeTrialOrder(trialOrderNodes); 
            else
                error('runExperiment: no experiment tag found in xml'); 
            end
        end
        
    end
    
    methods (Static)
        
    	function experiment = initializeExperiment(experimentNode)
    		experiment = Experiment(experimentNode);
    	end

        function targets = initializeTargets(targetNodes)
            if (targetNodes.getLength > 0)
                targetNodesLength = targetNodes.getLength; 
                targets = containers.Map; 
                for i = 0:targetNodesLength-1
                    currTargetNode = targetNodes.item(i); 
                    type = Utils.strToChar(currTargetNode.getAttribute('type')); 
                    if (strcmp(type, Dot.XML_TAG_TARGET_DOT))
                        dotObj = Dot(currTargetNode); 
                    elseif (strcmp(type, Rect.XML_TAG_TARGET_RECT))
                        dotObj = Rect(currTargetNode); 
                    end
                    targets(dotObj.Id) = dotObj; 
                end
            end
        end
        
        function movements = initializeMovements(movementNodes)
            if (movementNodes.getLength > 0)
                movements = containers.Map;
                for i = 0:movementNodes.getLength-1
                    movementObj = LinearMovement(movementNodes.item(i)); 
                    movements(movementObj.Id) = movementObj; 
                end
            end
        end

        function propertyChanges = initializePropertyChanges(propertyChangeNodes)
        	if (propertyChangeNodes.getLength > 0)
        		propertyChanges = containers.Map; 
        		for i = 0:propertyChangeNodes.getLength-1
        			propertyChangeObj = PropertyChange(propertyChangeNodes.item(i));
        			propertyChanges(propertyChangeObj.id) = propertyChangeObj; 
        		end
        	end
        end
        
        function backgrounds = initializeBackgrounds(backgroundNodes)
            if (backgroundNodes.getLength > 0)
                backgrounds = containers.Map;
                for i = 0:backgroundNodes.getLength-1
                    backgroundObj = Background(backgroundNodes.item(i)); 
                    backgrounds(backgroundObj.Id) = backgroundObj; 
                end
            end
        end
        
        function trials = initializeTrials(trialNodes, targets, movements, propertyChanges, backgrounds)
            if (trialNodes.getLength > 0)
                trials = containers.Map; 
                for i = 0:trialNodes.getLength-1
                    currTrial = ExperimentTrial(trialNodes.item(i), targets, movements, propertyChanges, backgrounds);
                    trials(currTrial.Id) = currTrial; 
                end
            end
        end
        
        function trialOrder = initializeTrialOrder(trialOrderNodes)
            if (trialOrderNodes.getLength > 0)
                trialOrderNode = trialOrderNodes.item(0); 
                trialOrder = Utils.strToArrayPreserveElemStrings(trialOrderNode.getAttribute('order'));
                if (Utils.strToInt(trialOrderNode.getAttribute('shuffle')))
                    trialOrder = trialOrder(randperm(length(trialOrder))); 
                end
            end
        end

    end
    
end