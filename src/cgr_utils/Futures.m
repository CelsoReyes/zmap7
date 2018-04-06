classdef Futures
    %FUTURES provides compatibility for MATLAB functions that change from version to version
    %   Use this class to avoid having to refactor
    % as important version changes happen in the code, add them here.
    %
    % NOTE: it is named FUTURES because it conflicted with Parallel toolbox Future
    %
    % Celso G Reyes
    %
    
    % Notes for functions maybe of interest, added later:
    %   R2017b 
    %      binscatter : essentially a 2d histogram that adjusts bins as you zoom in
    %      heatmap :
    %      geobubble : plot features
    
    properties (Constant)
        % as of R2017B,  uimenu's callbacks are now MenuSelectedFcn
        MenuSelectedFcn = Futures.chooseByVersion('R2017B','Callback','MenuSelectedFcn');
        
        % newlines were introduced in R2016b. 
        % the new version is a function handle that will be evaluated only if we are in the
        % higher version. This keeps us from throwing errors if it isn't implemented yet
        newline = Futures.chooseByVersion('R2016b',char(10),@newline,'evaluated')
        
        % polyshape, introduced in R2017b
    end
    
    methods
    end
    
    methods(Static)
        function val = chooseByVersion( minVer, older,newer, evaluated)
            evaluateFunction=exist('evaluated','var') && strcmp(evaluated,'evaluated');
            
            if startsWith(minVer,'R')
                switch upper(minVer)
                    case 'R2016B'
                        minVer='9.1';
                    case 'R2017A'
                        minVer='9.2';
                    case 'R2017B'
                        minVer='9.3';
                    case 'R2018A'
                        minVer='9.4';
                    otherwise
                        error('cannot translate Release %s to a version number',minVer');
                end
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
    end
end

