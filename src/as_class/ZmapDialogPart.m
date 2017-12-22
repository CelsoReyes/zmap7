classdef ZmapDialogPart < matlab.mixin.Heterogeneous
    %ZMAPDIALOGPART base class for items added to a dialog box
    %
    % this inherits from matlab.mixin.Heterogenous to allow one to create an array of
    % ZmapDialogPart.
    
    properties
        height=15
        width=330
        tooltip=''
        tag=''
        h
    end
    
    methods(Access=public, Abstract)
         obj=draw(obj,fig, minx, miny)
         v=Value(obj)
    end
    methods(Access=public)
        function hide(obj)
            obj.h.Visible='off';
        end
        function show(obj)
            obj.h.Visible='on';
        end
        function enable(obj)
            obj.h.Enable='on';
        end
        function disable(obj)
            obj.h.Enable='off';
        end
    end
    
    methods(Access=protected)
        %% helper functions
        function [userData, mystr] = value2String(className, label, value)
            userData=[]; % used when interpreting durations
            switch className
                case 'datetime'
                    mystr=string(value,'uuuu-MM-dd hh:mm:ss');
                case 'duration'
                    if contains(lower(label),{'year','yr'})
                        userData=1;
                        mystr=years(value);
                    elseif contains(lower(label),'day')
                        userData=3;
                        mystr=days(value);
                    elseif contains(lower(label),{'hr','hour'})
                        userData=4;
                        mystr=hours(value);
                    elseif contains(lower(label),'min')
                        userData=5;
                        mystr=minutes(value);
                    elseif contains(lower(label),'sec')
                        userData=6;
                        mystr=seconds(value);
                    else
                        error('label for a duration field must contain some indication of the units')
                    end
                otherwise
                    mystr=string(value);
                    if ismissing(mystr)
                        mystr='';
                    end
            end
        end
        
        %% callbacks
        function cb_str2numeric(src,~)
            % default callback that updates value for a string
            src.Value=str2double(src.String);
            src.UserData=src.Value;
        end
        
        function cb_str2datetime(src,~)
            src.UserData=datetime(src.String);
        end
        
        function cb_str2duration(src,~)
            % value encodes the original type
            % 1 year, 3 day, 4 hour, 5 minute, 6 second
            % (
            persistent getduration
            if isempty(getduration)
                getduration = {... to be indexed by type
                    @(s) years(str2double(s.String)); ...   1 : years
                    @(s) error('not a known function');...  2 : months (not applicable
                    @(s) days(str2double(s.String));...     3 : days
                    @(s) hours(str2double(s.String));...    4 : hours
                    @(s) minutes(str2double(s.String));...  5 : minutes
                    @(s) seconds(str2double(s.String)) ...  6 : seconds
                    };
            end
            
            src.UserData = getduration{src.Value}(src);
        end
        
        function cb_str2str(src,~)
            src.UserData=src.String; % duplicates data, but makes retrieval easy
        end
        
    end
end
