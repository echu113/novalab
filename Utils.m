classdef Utils

    methods (Static)
        
        function double = strToDouble(str)
            double = str2double(char(str)); 
        end
        
        function int = strToInt(str)
            int = floor(str2double(char(str))); 
        end
        
        function charStr = strToChar(str)
            charStr = char(str);
        end
        
        function array = strToArray(str)
            array = Utils.convertStrToArray(str, false); 
        end
        
        function array = strToArrayPreserveElemStrings(str)
            array = Utils.convertStrToArray(str, true); 
        end
        
    end
    
    methods (Static, Access = private)
        
        function array = convertStrToArray(string, preserveStringType)
            minStrLength = 3; 
            if (length(string) >= minStrLength)
                charString = Utils.strToChar(string); 
                charString = charString(2:length(charString)-1); % trim it
                strArray = strsplit(charString); 
                if (preserveStringType)
                    array = cell(1, length(strArray));
                    for i = 1:length(strArray)
                        array(i) = strArray(i); 
                    end
                else
                    array = zeros(1, length(strArray));
                    for i = 1:length(strArray)
                        array(i) = Utils.strToDouble(strArray(i)); 
                    end
                    
                end
            else
                array = []; 
            end
        end
        
    end
    
   
end
