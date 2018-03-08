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

    allData = fileread(filename);
    tagOpen = strfind(allData, '<');
    tagClose = strfind(allData, '>');

    if ~exist('showProgress') || isempty(showProgress)
        showProgress = length(tagOpen) > 1000;
    end

    if showProgress
        fprintf(repmat(' ', 1, 21));
    end

    stack = MatlabXMLElement('#document#', containers.Map());
    for tagIdx=1:length(tagOpen)
        if showProgress && mod(tagIdx, 100) == 0
            fprintf([repmat('\b', 1, 21) '%10i/%10i'], tagIdx, length(tagOpen));
        end

        start = tagOpen(tagIdx);
        stop = tagClose(tagIdx);


        tagData = allData(start+1:stop-1);

        % Special-case XML declaration
        if tagIdx == 1 && tagData(1) == '?' && tagData(end) == '?'
            tagData = tagData(2:end-1);
            attrs = regexp(tagData, '(?<key>\w+)="(?<value>[^"]*)"', 'names');
            for attr=attrs
                stack(end).Attributes(attr.key) = attr.value;
            end
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
            AddChild(stack(end), MatlabXMLElement(tagName, tagAttrs));
        elseif isOpening
            stack = [stack MatlabXMLElement(tagName, tagAttrs)];
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
