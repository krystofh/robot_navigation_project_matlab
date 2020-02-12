classdef Node
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position   % (i,j) position of the node
        parentNode % previous node on the path
        g          % cost to arrive at the current node
        h          % estimated cost to the end
        f          % total cost, f = g+h
    end
    
    methods
        function obj = Node(position,parentNode)
            %NODE Construct an instance of this class
            %   Detailed explanation goes here
            obj.position = position;
            obj.parentNode = parentNode;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

