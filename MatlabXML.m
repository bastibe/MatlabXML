function element = MatlabXML(filename, showProgress)
%MatlabXML(filename) reads an XML file into nested MatlabXMLElements
%   Why not use xmlread? Because xmlread will choke on large files.
%
%   Each MatlabXMLElement is an object with properties:
%   - Name as string
%   - Attributes as containers.Map
%   - Children as array of MatlabXMLElements
%
%   The returned MatlabXMLElement is always "#document#", with the XML
%   declaration attributes as attributes and the root element as its
%   only child.
%
%   MatlabXML(..., showProgress) controls wether a progress counter is
%       shown while parsing. By default, a progress counter is shown
%       for files with more than 1000 elements.

% Copyright (C) 2018 Bastian Bechtold
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% For the full text of the GNU General Public License, see
% <https://www.gnu.org/licenses/>.

    allData = fileread(filename);
    tagOpen = strfind(allData, '<');
    tagClose = strfind(allData, '>');
    tagValue = strfind(allData, '</');
    tagValueIndex = 1;
    
    if ~exist('showProgress') || isempty(showProgress)
        showProgress = length(tagOpen) > 1000;
    end

    if showProgress
        fprintf(repmat(' ', 1, 21));
    end

    stack = MatlabXMLElement('#document#', containers.Map(), ' ');
    for tagIdx=1:length(tagOpen)
        if showProgress && mod(tagIdx, 100) == 0
            fprintf([repmat('\b', 1, 21) '%10i/%10i'], tagIdx, length(tagOpen));
        end

        start = tagOpen(tagIdx);
        stop = tagClose(tagIdx);


        tagData = allData(start+1:stop-1);

        value = ' ';
        if tagIdx ~= length(tagOpen)
            if tagOpen(tagIdx+1) == tagValue(tagValueIndex)
                value = (allData(tagClose(tagIdx+1-1)+1:tagOpen(tagIdx+1)-1));
                tagValueIndex = tagValueIndex + 1;
            end
        end
        
        % Special-case XML declaration
        if tagIdx == 1 && tagData(1) == '?' && tagData(end) == '?'
            tagData = tagData(2:end-1);
            attrs = regexp(tagData, '(?<key>\w+)="(?<value>[^"]*)"', 'names');
            for attr=attrs
                stack(end).Attributes(attr.key) = attr.value;
            end
            continue
        end
        
        if tagData(1) == '!'
            continue
        end

        isComplete = tagData(end) == '/';
        isOpening = tagData(1) ~= '/';
        if isComplete
            tagData = tagData(1:end-1);
        elseif ~isOpening
            tagData = tagData(2:end);
        end

        tagName = regexp(tagData, '^(?<name>\w+)', 'names');
        tagName = tagName.name;
        attrs = regexp(tagData, '(?<key>\w+)="(?<value>[^"]*)"', 'names');
        tagAttrs = containers.Map();
        for attr=attrs
            tagAttrs(attr.key) = attr.value;
        end

        if isComplete
            AddChild(stack(end), MatlabXMLElement(tagName, tagAttrs, value));
        elseif isOpening
            stack = [stack MatlabXMLElement(tagName, tagAttrs, value)];
        else % is closing
            element = stack(end);
            stack = stack(1:end-1);
            AddChild(stack(end), element);
        end
    end

    if showProgress
        fprintf([repmat('\b', 1, 21) repmat(' ', 1, 21) repmat('\b', 1, 21)]);
    end

    element = stack(1);
end
