classdef LimitScope < handle
    % LIMITSCOPE adds scope-dependency to graphical handle objects. 
    %
    % For example, a message box can display a message at the beginning of a function, and 
    % then be automatically be deleted when the function exits. Alternatively, properties can be
    % tied to the current scope.  That is, within the current function some property, like
    % 'Visible', 'Checked', 'Value', 'String', or 'Enable' can be set within a function, and then 
    % automatically revert to a new value when the function is exited.
    %
    % 
    % SC = LIMITSCOPE(graphicshandle) will delete graphicshandle when SC is assigned a new value or
    % when SC goes out of scope (for example, when leaving a function)
    %
    % SC = LIMITSCOPE(graphicshandle, PROPERTY, INSCOPEVAL, LEAVESCOPEVAL) will, instead
    % of deleting the item, modify a property of the item.  When LIMITSCOPE is first called, the
    % property will be assigned INSCOPEVAL. When lifetime of LIMITSCOPE is over, then the property
    % is assigned ELAVSCOPEVAL.
    %
    % SC = LIMITSCOPE(graphicshandle, ..., DURATION) will pause execution for for the specified
    % duration before deleting the associated handle.  DURATION can be a duration or # of seconds. 
    % If the graphics handle is invalidated (ie. figure is closed) before the specified duration has
    % elapsed, then program execution continues.
    %
    % if the LIMITSCOPE object is not assigned to a variable, then it will go out of scope once 
    % ans is overwritten
    %
    %
    % Example 1: create a message box that is replaced when the next mesagebox is created
    %
    %     mb=msgbox('Close when variable is reassigned.','wait reassignment');
    %     test=LimitScope(mb);
    %     pause(3)
    %     test=LimitScope(msgbox('Now I have something new to show','overwritten'));
    %     pause(3)
    %     test=[]
    %
    % Example 2: highlight a points on a line while they are analyzed [contrived example]
    %
    %     x=[1:20]; y=randi(50,[1,20]);
    %     plot(x,y);
    %     for n=1:3
    %         idx= randsample(x,8);
    %         set(gca,'NextPlot','add')
    %         sc = scatter(x(idx),y(idx),'o');
    %         d = text(x(idx(2)),y(idx(2)),'Notice here...')
    %         tmp=LimitScope([sc d]);
    %         pause(2); % pretend to be computing something
    %     end
    %     clear tmp % clearing or reassigning tmp deletes the items from the plot
    %
    % Example 3: changing properties based on scope
    %  
    %     function playing()
    %         mb = msgbox('Test','test');
    %         mbb=findobj(mb,'Style','pushbutton');
    %         mbt=findobj(mb,'Type','text');
    %
    %         % ensure that the msgbox is deleted when this function ends
    %         lifetimecontrol = LimitScope(mb);
    %
    %         % set font to bold until tmpT is changed
    %         tmpT=LimitScope(mbt,'FontWeight','bold','normal');
    %         LimitScope(mbb,'Enable','off','on', seconds(3)); % disable button for 3 secs
    %         LimitScope(mbb,'Visible','off','on', seconds(2)); % make button invisible for 2 secs
    %         LimitScope(mbb,'BackgroundColor','r',mbb.BackgroundColor, 3); % change color for 3 secs
    %         tmpT=LimitScope(mbt,'String','TESTING!',mbt.String); % change the display string
    %         pause(2); pause long enough to see the string change
    %     end
    %
    % Celso G Reyes
    % Zurich, Switzerland 2018
    
    properties
        h;
        fieldToChange='';
        leaveScopeValue='';
    end
    methods
        function obj=LimitScope(myhandle, varargin) % dur, fieldToChange, inScopeValue, leaveScopeValue)
            assert(all(ishandle(myhandle) & isvalid(myhandle)));
            obj.h=myhandle;
            
            switch nargin
                case 1
                    % delete handle when this goes out of scope
                case 2
                    % duration was provided
                    dur=varargin{end};
                case 4
                    % using scoped field values
                    obj.fieldToChange=varargin{1};
                    inScopeValue=varargin{2};
                    obj.leaveScopeValue=varargin{3};
                case 5 
                    % using scoped field values with a duration.
                    obj.fieldToChange=varargin{1};
                    inScopeValue=varargin{2};
                    obj.leaveScopeValue=varargin{3};
                    dur=varargin{end};
            end
            if exist ('inScopeValue','var')
                set(obj.h, obj.fieldToChange, inScopeValue);
            end
                
            if exist('dur','var') && isscalar(dur) && (isnumeric(dur) || isduration(dur))
                obj.delay_for_close(dur);
            end
        end
        
        function delete(obj)
            if ~isempty(obj.fieldToChange)
                set(obj.h(isvalid(obj.h)), obj.fieldToChange,obj.leaveScopeValue);
            else
                
                try
                    delete(obj.h(isvalid(obj.h)));
                catch ME
                    warning(ME.message);
                end
            end
        end
        
        function delay_for_close(obj, dur)
            % DELAY_FOR_CLOSE waits maximum DUR seconds for user to close item
            if isnumeric(dur)
                dur=seconds(dur);
            end
            if dur > minutes(1)
                warning('duration seems fairly long %s. MATLAB is paused in meantime',char(dur))
            end
            finish = datetime + dur;
            while datetime < finish && any(isvalid(obj.h))
                pause(.2);
            end
            delete(obj)
        end
            
    end
    
    methods(Static)
        function test()
            % TEST
            % msgbox_nobutton.test(5) % waits 5 seconds before completing
            
            mb=msgbox(['test ' char(datetime), ' Will close when variable is reassigned or cleared.'],'wait reassignment');
            test=LimitScope(mb); %#ok<NASGU>
            disp('pausing...')
            pause(3)
            test=[];  %#ok<NASGU> % reusing or clearing the LimitScope item deletes the associated item
            assert(~isvalid(mb));
            
            mb=msgbox(['test ' char(datetime), ' Will pause 5 seconds or until user makes it disappear.'],'timer associated');
            test=LimitScope(mb, seconds(5));
            % test is now a handle to a deleted object. Further use would result in an error
            assert(~isvalid(mb));
            assert(~isvalid(test));
            % should self delete at end of function
            
            mb=msgbox(['test ' char(datetime), ' Will close when function exits.'],'function-associated');
            limited_scope(mb)
            assert(~isvalid(mb));
            
            function limited_scope(myhandle)
                
                x=LimitScope(myhandle); %#ok<NASGU>
                disp('Function pausing for 2 seconds')
                pause(2)
                disp('done pausing. ending function')
            end
        end
        function testproperty()
            mb = msgbox('Test','test');
            mbb=findobj(mb,'Style','pushbutton');
            mbt=findobj(mb,'Type','text');
            
            % ensure that the msgbox is deleted when this function ends
            lifetimecontrol = LimitScope(mb); %#ok<NASGU>
            pause(1)
            
            % set font to bold until tmpT is changed
            tmpT=LimitScope(mbt,'FontWeight','bold','normal'); %#ok<NASGU>
            
            assert(mbt.FontWeight == "bold");
            
            % disable the button for 3 seconds.
            LimitScope(mbb,'Enable','off','on', seconds(3));
            
            % program pauses, so by the time it reaches here, it should be on again 
            assert(mbb.Enable == "on"); 
            
            %  change the button color for 3 seconds before resetting it
            LimitScope(mbb,'BackgroundColor','r',mbb.BackgroundColor, 3);
            
            % font should still be bold until we reassign tmpT
            assert(mbt.FontWeight == "bold");
            
            % change the display string
            tmpT=LimitScope(mbt,'String','TESTING!',mbt.String); %#ok<NASGU>
            
            assert(mbt.FontWeight == "normal");
            assert(mbt.String == "TESTING!");
            
            pause(3)
            
        end
    end
end

    