function element = MatlabXML(filename)
%MatlabXML reads an XML file into a nested MatlabXMLElements
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

    allData = fileread(filename);
    tagOpen = strfind(allData, '<');
    tagClose = strfind(allData, '>');

    stack = MatlabXMLElement('#document#', containers.Map());
    for tagIdx=1:length(tagOpen)
        if mod(tagIdx, 100) == 0
            fprintf([repmat('\b', 1, 21) '%10i/%10i'], tagIdx, length(tagOpen));
        end
        start = tagOpen(tagIdx);
        stop = tagClose(tagIdx);


        tagData = allData(start+1:stop-1);

        % Special-case XML declaration
        if tagIdx == 1 && tagData(1) == '?' && tagData(end) == '?'
            tagData = strip(tagData, '?');
            attrs = regexp(tagData, '(?<key>\w+)="(?<value>[^"]*)"', 'names');
            for attr=attrs
                stack(end).Attributes(attr.key) = attr.value;
            end
            continue
        end

        isComplete = tagData(end) == '/';
        isOpening = tagData(1) ~= '/';
        tagData = strip(tagData, '/');

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
    fprintf(repmat('\b', 1, 22));
    element = stack(1);
end
