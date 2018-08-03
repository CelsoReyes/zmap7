classdef ZmapFigureFunction < ZmapFunction
    % ZMAPFIGUREFUNCTION is an interactive figure that is reused
    %    - can be refreshed
    %    - has menu items
    properties(Constant,Abstract)
        FigTag % tag for this figure
    end
    
    properties
        FigureDetails; % cell containing figure parameters (other than tag)
    end
    
    properties(Dependent)
        hFig % handle to this figure
    end
    
    methods(Abstract)
        CreateMenu(obj)
        ClearFigure(obj)
    end
        
    methods
        function fig = get.hFig(obj)
            fig=findobj('Tag',obj.FigTag,'-and','Type','Figure');
        end
        
        function doIt(obj)
           CreateFigure(obj);
            % do it is redefined here 
        end
        
        function CreateFigure(obj)
            fig = obj.hFig;
            if isempty(obj.hFig)
                fig=figure('Tag',obj.FigTag,obj.figureDetails{:});
                obj.CreateMenu();
                assert(~isempty(fig) && isvalid(fig),'problem creating figure');

                obj.Calculate();
                obj.plot();
            else
                assert(~isempty(fig) && isvalid(fig),'problem creating figure');
                % duplicated in case a refresh/clearplot is necessary first
                obj.Calculate();
                obj.plot();
                
            end
        end
    end
end