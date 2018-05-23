classdef msgbox_nobutton < handle
    % MSGBOX_NOBUTTON msgbox without "OK" button that disappears when variable goes out of scope
    % 
    % if not assigned to a variable, then it will go out of scope as soon as ans is overwritten
    properties
        h
    end
    properties(Access=private)
        OKButton
        Message
    end
    properties(Dependent)
        String
        ButtonVisible
        ButtonString
        Name
    end
    methods
        function obj=msgbox_nobutton(varargin)
            obj.h = msgbox(varargin{:});
            obj.OKButton=findobj(obj.h,'Tag','OKButton');
            obj.Message=findobj(obj.h,'Tag','MessageBox');
            obj.ButtonVisible=false;
            watchon;
            drawnow nocallbacks
        end
        
        function set.ButtonVisible(obj,val)
            if ~isvalid(obj.h)
                return
            end
            if val
                obj.OKButton.Visible='on';
            else
                obj.OKButton.Visible='off';
            end
        end
        
        function set.String(obj,s)
            if isvalid(obj.Message)
            obj.Message.String=s;
            end
        end
        
        function set.ButtonString(obj,s)
            if isvalid(obj.OKButton)
                obj.OKButton.String=s;
            end
        end
            
        function set.Name(obj,s)
            if isvalid(obj.h)
            obj.h.Name=s;
            end
        end
            
        function delete(obj)
            try
                delete(obj.h);
            catch ME
                warning(ME);
            end
        end
        
        function delay_for_close(obj, dur)
            % DELAY_FOR_CLOSE(dur) how long to wait before closing automatically. (in seconds)
            if isnumeric(dur)
                dur=seconds(dur);
            end
            if dur > seconds(30)
                warning('duration seems fairly long %s. MATLAB is paused in meantime',char(dur))
            end
            finish = datetime + dur;
            obj.ButtonVisible=true;
            while datetime < finish && isvalid(obj.h)
                pause(.2);
            end
        end
            
        function move_to_mouse(obj)
            if ~isvalid(obj.h)
                return
            end
            pl = get(groot,'PointerLocation');
            myWidth= obj.h.Position(3);
            myHeight=obj.h.Position(4);
            newpos=pl - [ myWidth myHeight]./2;
            obj.h.Position([1 2]) = newpos;
            figure(obj.h);
        end
    end
    
    methods(Static)
        function test(dur)
            % TEST
            % msgbox_nobutton.test(5) % waits 5 seconds befoe completing
            tmp=msgbox_nobutton(['test' char(datetime)],'test test test'); %#ok<NASGU>
            pause(dur);
            % should self delete at end of function
        end
    end
end

    