classdef Futures
    %%
    % FUTURES provides compatibility for MATLAB functions that change from version to version
    % Use this class to avoid scattering  |if verLessThan(),...else,...end|  throughout your code.
    %
    % 
    %  usage example:
    %    in R2017a, uimenu callbacks are labeled with 'Callback' , but in R2017b and beyond,
    %    these are supposed to be labeled with 'MenuSelectedFcn'.
    %
    %    to maintain compatability both before and after the change, one might do something like:
    %
    %       m=uimenu('Label','SetThisCallbackLater');
    %
    %       % .... some intermediate code...
    % 
    %       if verLessThan('matlab','9.3')
    %           uimenu('Label','setRightNow','Callback',@do_something); 
    %           m.Callback = @do_something;   % delayed assignment using fieldnames
    %       else
    %           uimenu('Label','setRightNow','MenuSelectedFcn',@do_something);
    %           m.MenuSelectedFcn = @do_something;
    %       end
    %
    %
    %  Using this class, you can do the following instead:
    %
    %       m=uimenu('Label','SetThisCallbackLater');
    %
    %       % .... some intermediate code...
    % 
    %       uimenu('Label','setRightNow',Futures.MenuSelectedFcn,@do_something); 
    %       m.(Futures.MenuSelectedFcn) = @do_something;   % delayed assignment using fieldnames
    %
    %
    % The chooseByVersion function COULD be used by itself, but if you start scattering the same
    % statement throughout your code, it might be better consolidated here
    %
    % NOTE: it is named FUTURES because it FUTURE was taken by the Parallel toolbox.
    %
    %
    % Celso G Reyes, PhD
    % Zuerich, Switzerland
    
    % constant properties are evaluated the first time Futures is called.
    properties (Constant)
        % as of R2017B,  uimenu's callbacks are now MenuSelectedFcn
        MenuSelectedFcn = Futures.chooseByVersion('R2017B','Callback','MenuSelectedFcn');
        
        % newlines were introduced in R2016b. 
        % the new version is a function handle that will be evaluated only if we are in the
        % higher version. This keeps us from throwing errors if it isn't implemented yet
        newline = Futures.chooseByVersion('R2016b',char(10), @newline,'evaluated')
        
        %% add your own permanent stuff here
    end
    
    methods(Static)
        function val = chooseByVersion( minVer, older,newer, evaluated)
            % CHOOSEBYVERSION chooses between values based upon matlab version
            %
            % val = CHOOSEBYVERSION(minVer , olderValue, newerValue) compares the current matlab 
            % version to minVer. if an earlier version of MATLAB is used, then returns olderValue.
            % otherwise, returns the newerValue.
            % 
            %
            % val = CHOOSEBYVERSION(..., evaluateIfFunctionHandle) where true or false [default]
            % will also evaluate the value if it happens to be a function handle.  This is so that
            % a version dependent function could be called, without erroring in the version where
            % it doesn't exist.
            %
            % example (run in matlab  R2017a (9.2):
            %   >> chooseByVersion('9.3','old','new')
            %   'old'
            %   >> chooseByVersion('9.2','old','new')
            %   'new'
            %
            % see also VERLESSTHAN
            
            evaluateFunction=exist('evaluated','var') && evaluated == "evaluated";
            
            if any(startsWith(minVer,{'(R','R'}))
                minVer=Futures.release2version(minVer);
            end
            
            if verLessThan('matlab',minVer)
                if evaluateFunction && isa(older,'function_handle')
                    val=older();
                else
                    val=older;
                end
            else
                if evaluateFunction && isa(newer,'function_handle')
                    val=newer();
                else
                    val=newer;
                end
            end
        end
        function ver = release2version(rel)
            % RELEASE2VERSION converts from a release string to a version.
            % ver = RELEASE2VERSION( rel )
            %
            %  example:
            %     >> Futures.RELEASETOVERSION( 'R2016B' )
            %     '9.1'
            
            rel=replace(rel,{'(',')'},''); % get rid of parenthesis
            vermap = {...
                'R2015B','8.6';
                'R2016A','9.0';
                'R2016B','9.1';
                'R2017A','9.2';
                'R2017B','9.3';
                'R2018A','9.4'
                %% add your own here
                };
            ver=vermap{strcmpi(vermap,rel),2};
            if isempty(ver)
                error('cannot translate Release %s to a version number',rel');
            end
        end
    end
end

