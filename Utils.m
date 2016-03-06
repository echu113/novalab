classdef Utils

    properties (Constant)
        
        TYPE_DOUBLE = 'double'; 
        TYPE_INT = 'integer'; 
        TYPE_STRING = 'string'; 
        TYPE_STRING_ARRAY = 'stringArray'; 
        TYPE_DOUBLE_ARRAY = 'doubleArray'; 

    end

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

        function str = getValueFromMap(map, key)
            if (map.isKey(key))
                str = map(key); 
            else
                str = ''; 
            end
        end

        function map = xmlNodeToMap(xmlNode)
            map = containers.Map; 
            attributes = xmlNode.getAttributes; 
            if (attributes.getLength >= 1)
                for i = 0:(attributes.getLength - 1)
                    attributeName = Utils.strToChar(attributes.item(i).getName); 
                    rawValue = attributes.item(i).getValue; 
                    % attributetype = XmlParser.getAttributeType(xmlNode.getNodeName, attributeName); 
                    map(attributeName) = rawValue; 
                end
            end
        end

        function value = getValueWithType(attributeValue, expectedType)
            if (strcmp(expectedType, Utils.TYPE_DOUBLE))
                value = Utils.strToDouble(attributeValue); 
            elseif (strcmp(expectedType, Utils.TYPE_INT))
                value = Utils.strToInt(attributeValue); 
            elseif (strcmp(expectedType, Utils.TYPE_STRING))
                value = Utils.strToChar(attributeValue); 
            elseif (strcmp(expectedType, Utils.TYPE_STRING_ARRAY))
                value = Utils.strToArrayPreserveElemStrings(attributeValue); 
            elseif (strcmp(expectedType, Utils.TYPE_DOUBLE_ARRAY))
                value = Utils.strToArray(attributeValue); 
            end
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
