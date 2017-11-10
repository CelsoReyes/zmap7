classdef ValueMap
    % ValueMap displays results from certain operations
    %
    % one should be able to pass this a table, and it will plot
    % the results on the map.  Any column from the table can be plotted
    % 
    % obj = ValueMap(table_of_results, Xs, Ys, tag)
    % fig = obj.createFigure(fig, varargin) % creates figure and adds name to top
    % obj.addMenu(fig); % add a menu that allows one to 
    % obj.pcolor(ax, column)
    % obj.scatter(ax, column, sizescalefunction, colorfunction)
    %
    % see also ZmapQuickResultPcolor
    
    properties
        tag
        tbl
        Xs
        Ys
    end
    methods
        function obj = ValueMap(resultsTable,...
                figureName,...
                displayColName,...
                menuFunctions,...
                tag)
            % resultsTable - table of results
            % displayColName - column name of results to map
            % menuFunctions - cell of functions used to create top-level menus.
            % tag - unique tag name used to access this figure. Only one figure with this
            % tag will be created. Any figure with this name will be deleted and recreated as this.
            %
            % see also ZmapQuickResultPcolor
            obj.tag = tag;
            h = findobj('Type','figure','-and','Tag',tag);
        end
        function fig = obj.createFigure(fig, varargin)
            % CREATEFIGURE creates a figure and 
        end
        
        function pcolor(obj)
            
        end
        
        function scatter(obj. ax, sizecol, sizefun, colorcol, colorfun)
            % scatter
            % 
            % if SIZEFUN is a string, it is assumed to be a column that controls the size
            % if COLORFUN is a string, it is 
            if isempty(sizefun)
                sizefun=@(x) x;
            end
            if isempty(colorfun)
                colorfun=@(x) x;
            end
            scatter(ax,Xs,Ys,sizefun(obj.tbl.(sizecol)), 
        end
    end
end