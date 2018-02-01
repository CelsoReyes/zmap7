classdef Stack < handle
    % STACK push-pop stack for storing items and retrieving LIFO
    %
    % STACK() create a stack that can grow indefinitely
    % STACK(MAXSIZE) define the maximum size of the stack.
    % 
    % STACK METHODS:
    % PUSH - add the thing to the top of the stack. If stack is full, items fall off the back side.
    % POP - pull an item from top of the stack. If stack is empty, will error
    % ISEMPTY - return whether items exist on the stack
    %
    % PEEK - look at most recent item
    
    properties
        items={}; % contains items on the stack
        maxsize = inf; % maximum size of stack
    end
    methods
        function obj = Stack(maxsize)
            if nargin > 0
                assert(maxsize > 0,'maximum Stack size must be greater than zero')
                obj.maxsize=maxsize;
            end
        end
        
        function push(obj,thing)
            if numel(obj.items) < obj.maxsize
                obj.items(end+1)={thing};
            else
                obj.items=circshift(obj.items,-1);
                obj.items(end)={thing};
            end
        end
        
        function item=pop(obj)
            if numel(obj.items) > 0
                item=obj.items{end};
                obj.items(end)=[];
            else
                error('No items exist to pop from stack');
            end
        end
        
        function tf = isempty(obj)
            % ISEMPTY returns true if there are items on the stack
            tf = isempty(obj.items);
        end
        function item = peek(obj)
            % PEEK retrieve last item without popping it
            if ~isempty(obj)
                item = obj.items{end};
            else
                item=[];
            end
        end
    end
    
    methods (Static)
        function test()
            % test numbers
            maxSize=5;
            overshoot = 2;
            values = 1 : maxSize + overshoot;
            s=Stack(maxSize);
            for y= 1 : numel(values)
                s.push(values(y))
                assert(s.pop()==values(y));
                s.push(values(y))
            end
            expected = values(overshoot+1:end);
            while ~isempty(s)
                last = s.pop();
                assert(last==expected(end));
                expected(end)=[];
            end
            assert(isempty(expected))
        end
        
    end
            
            
end
