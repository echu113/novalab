classdef XmlParser
    
    properties (Constant)
        XML_TAG_EXPERIMENT = 'experiment'; 
        XML_TAG_TARGET = 'target'; 
        XML_TAG_MOVEMENT = 'movement' 
        XML_TAG_PROPERTY_CHANGE = 'propertyChange'; 
        XML_TAG_BACKGROUND = 'background'; 
        XML_TAG_TRIAL = 'trial'; 
        XML_TAG_TRIAL_ORDER = 'trialOrder'; 
        XML_TAG_TRIAL_DEFAULT = 'defaultConfig';
    end
    
    properties (Access = public)
    	Experiment; % single experiment exist at once, ignore the rest
        Targets; 
        Movements; 
        PropertyChanges; 
        Backgrounds; 
        Trials; 
        TrialOrder; 
        trialDefaults; 
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
                
                trialDefaultNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TRIAL_DEFAULT);
                obj.trialDefaults = XmlParser.initializeTrialDefaults(trialDefaultNodes);

                trialNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TRIAL); 
                obj.Trials = XmlParser.initializeTrials(trialNodes, obj.Targets, obj.Movements, obj.PropertyChanges, obj.Backgrounds, obj.trialDefaults); 
                
                trialOrderNodes = experimentNode.getElementsByTagName(XmlParser.XML_TAG_TRIAL_ORDER);
                obj.TrialOrder = XmlParser.initializeTrialOrder(trialOrderNodes, obj.Trials); 

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
            movements = containers.Map;
            if (movementNodes.getLength > 0)
                for i = 0:movementNodes.getLength-1
                    movementObj = LinearMovement(movementNodes.item(i)); 
                    movements(movementObj.Id) = movementObj; 
                end
            end
        end

        function propertyChanges = initializePropertyChanges(propertyChangeNodes)
            propertyChanges = containers.Map; 
            if (propertyChangeNodes.getLength > 0)
        		for i = 0:propertyChangeNodes.getLength-1
        			propertyChangeObj = PropertyChange(propertyChangeNodes.item(i));
        			propertyChanges(propertyChangeObj.id) = propertyChangeObj; 
        		end
        	end
        end
        
        function backgrounds = initializeBackgrounds(backgroundNodes)
            backgrounds = containers.Map;
            if (backgroundNodes.getLength > 0)
                for i = 0:backgroundNodes.getLength-1
                    backgroundObj = Background(backgroundNodes.item(i)); 
                    backgrounds(backgroundObj.Id) = backgroundObj; 
                end
            end
        end

        function trialDefaults = initializeTrialDefaults(defaultNodes)
            trialDefaults = containers.Map; 
            if (defaultNodes.getLength > 0)
                for i = 0:defaultNodes.getLength-1
                    currNode = defaultNodes.item(i); 
                    trialDefaults(Utils.strToChar(currNode.getAttribute('id'))) = Utils.xmlNodeToMap(currNode);
                end
            end
        end
        
        function trials = initializeTrials(trialNodes, targets, movements, propertyChanges, backgrounds, trialDefaults)
            trials = containers.Map; 
            if (trialNodes.getLength > 0)
                for i = 0:trialNodes.getLength-1
                    currTrialNode = trialNodes.item(i); 
                    
                    nodeMap = Utils.xmlNodeToMap(currTrialNode);
                    trialDefault = Utils.strToChar(Utils.getValueFromMap(nodeMap, XmlParser.XML_TAG_TRIAL_DEFAULT)); 

                    if (~isempty(trialDefault) && trialDefaults.isKey(trialDefault))
                        trialDefaultsMap = trialDefaults(trialDefault);
                        if (trialDefaultsMap.isKey('id'))
                            trialDefaultsMap.remove('id');
                        end
                        completeMap = [nodeMap ; trialDefaultsMap]; 
                    else
                        completeMap = nodeMap; 
                    end
                    
                    trialType = Utils.strToChar(Utils.getValueFromMap(completeMap, 'type')); 
                    numberOfTrials = Utils.strToInt(Utils.getValueFromMap(completeMap, 'numberOfTrials')); 
                    if (isnan(numberOfTrials))
                        numberOfTrials = 1; 
                    end
                    
                    for j = 1:numberOfTrials      
                        if (strcmp(trialType, GenericTrial.TRIAL_TYPE))
                            currTrial = GenericTrial(completeMap, targets, movements, propertyChanges, backgrounds);
                            trials(strcat(currTrial.Id, '#', num2str(j))) = currTrial; 
                        elseif (strcmp(trialType, EyeSoccerTrial.TRIAL_TYPE))
                            currTrial = EyeSoccerTrial(completeMap, targets, movements, propertyChanges, backgrounds);
                            trials(strcat(currTrial.Id, '#', num2str(j))) = currTrial; 
                        end
                    end

                end
            end
        end
        
        function trialOrder = initializeTrialOrder(trialOrderNodes, trials)
            if (trialOrderNodes.getLength > 0)
                trialOrderNode = trialOrderNodes.item(0); 
                trialOrder = Utils.strToArrayPreserveElemStrings(trialOrderNode.getAttribute('order'));
                if (isempty(trialOrder) && ~isempty(trials))
                    trialOrder = keys(trials);
                end
                if (logical(Utils.strToInt(trialOrderNode.getAttribute('shuffle'))))
                    trialOrder = trialOrder(randperm(length(trialOrder))); 
                end
            end
        end

    end
    
end