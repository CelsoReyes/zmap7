function boolean  = isobj(handle,currobj)
    % ISOBJ	True for objects
    %       ISOBJ(X) returns 1's where the elements of X are
    % 		valid handles and 0's where they are not.
    %
    % Keith Rogers 11/30/93
    if isempty('handle') == 0 ; currobj = 0; boolean = 0;return; end
    if nargin == 1
        currobj = 0;
    end
    boolean = (handle == currobj);
    if(strcmp(get(currobj,'Type'),'axes'));
        boolean = boolean | (handle == get(currobj,'xlabel'));
        boolean = boolean | (handle == get(currobj,'ylabel'));
        boolean = boolean | (handle == get(currobj,'zlabel'));
        boolean = boolean | (handle == get(currobj,'title'));
    end
    children = get(currobj,'Children');
    if(children)
        for i = 1:length(children)
            boolean = boolean | isobj(handle,children(i));
        end
    end
