classdef MatlabXMLElement < handle
% MatlabXMLElement stores an element, attributes and children
%
%   MatlabXMLElement(name, attributes) creates a new element.
%
%   Each MatlabXMLElement has three properties:
%   - Name as string
%   - Attributes as containers.Map
%   - Children as array of MatlabXMLElements
%
%   To add children, use AddChild(). Since this is a very frequent
%   operation, it needs to be fast. Internally, the children array
%   grows in factors of two, so each AddChild() is a simple store.

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

    properties
        Name
        Attributes
    end

    properties (Dependent)
        Children
    end

    properties (Hidden)
        ChildrenData
        ChildIdx
    end

    methods
        function obj = MatlabXMLElement(name, attributes)
            obj.Name = name;
            obj.Attributes = attributes;
            obj.ChildrenData = [];
            obj.ChildIdx = 0;
        end

        function AddChild(obj, child)
            % Children can grow very big, and linearly growing
            % obj.ChildrenData for every child will get slow quickly.
            % Instead, grow obj.ChildrenData by x2 whenever necessary.

            if isempty(obj.ChildrenData)
                obj.ChildrenData = child;
                obj.ChildIdx = 1;
                return
            end

            if length(obj.ChildrenData) == obj.ChildIdx
                obj.ChildrenData = [obj.ChildrenData obj.ChildrenData];
            end

            obj.ChildIdx = obj.ChildIdx + 1;
            obj.ChildrenData(obj.ChildIdx) = child;
        end

        function children = get.Children(obj)
            children = obj.ChildrenData(1:obj.ChildIdx);
        end
    end
end
