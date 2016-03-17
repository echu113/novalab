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
           
            fileId = fopen('the_response_data.txt', 'w'); 
            fprintf(fileId,'%20s %20s\r\n','trialId','response');

            % ids = cell(length(trialOrder)); 
            % responses = cell(length(trialOrder)); 

            for i = 1:length(trialOrder)
                
                currTrialId = trialOrder{i}; 
                currTrial = trials(currTrialId);

                ListenChar(2); 

                currTrial.runTrial(window); 
            
                % todo write to data file properly
                [ch, ~] = GetChar();            
                if (~isempty(ch))
                    % ids{i} = currTrialId;
                    % responses{i} = ch; 
                    fprintf(fileId, '%20s %20s\r\n', currTrialId, ch);
                end
                ListenChar(0);   
            end

            fclose(fileId); 
            
        else
            error('please specify trials to run'); 
        end
        sca; 
    end


end
