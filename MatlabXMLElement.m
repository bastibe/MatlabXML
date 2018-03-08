classdef MatlabXMLElement < handle
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
