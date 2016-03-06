function runExperiment(experimentXML)
    % Entry point function
            
    parser = XmlParser(experimentXML); 

    window = initWindow(parser.Experiment); 
    
    runTrials(parser.Trials, parser.TrialOrder, window); 
    
    function window = initWindow(experiment)
        
        Screen('Preference', 'SkipSyncTests', 1);
        
        PsychDefaultSetup(2);

        screens = Screen('Screens');
        screenNumber = max(screens);

        black = BlackIndex(screenNumber);

       	if (experiment.fullScreen)
   	        [window, ~] = PsychImaging('OpenWindow', screenNumber, black);
       	else
	        [window, ~] = PsychImaging('OpenWindow', screenNumber, black, experiment.screenCoord);
   		end
        
    end
    
    function runTrials(trials, trialOrder, window)
        if (~isempty(trialOrder))
            for i = 1:length(trialOrder)
                currTrialId = trialOrder{i}; 
                currTrial = trials(currTrialId);
                currTrial.runTrial(window); 
            end
        else
            error('please specify trials to run'); 
        end
        sca; 
    end


end
