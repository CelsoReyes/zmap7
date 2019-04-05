classdef ZmapHGridFunction < ZmapGridFunction
    % ZMAPHGRIDFUNCTION is a ZmapFunction that produces a grid of results plottable on map (horiz slice)
    %
    % plot results in a corresponding tab using obj.overlay(resTab, choice)
    % obj.interact handles the user interaction with the results
    %
    %
    %
    %
    %
    %
    %
    % see also ZMAPGRIDFUNCTION
    
    properties(SetObservable, AbortSet)
        features cell ={'borders'}; % features to show on the map, such as 'borders','lakes','coast',etc.
        
        nearestSample   = 0;         % current index (where user clicked) within the result table
        pointChoice (1,1) char   {mustBeMember(pointChoice,{'A','B','-'})}   = 'A'; % choose points for comparison. 'A', or 'B'
        samplePoints = containers.Map(); % track individual points
        
    end
        
    
    properties(Constant)
        Type = GridTypes.XY;
    end
    
    properties(Dependent)
        resultsForThisPoint      % table row corresponding to closest grid point
        resultsForThisPointNoNan % table row corresponding to closest grid point, excluding NAN columns
        selectionForThisPoint    % mask for catalog, true for events used in this point's calculations
        catalogForThisPoint      % events used in calculating values for this point
    end
        
    methods
        
        function obj=ZmapHGridFunction(varargin)
            obj@ZmapGridFunction(varargin{:});
            obj.addlistener('nearestSample','PostSet', @obj.update);
        end
        
        %% dependent properties
        
        function tb = get.resultsForThisPoint(obj)
            if obj.nearestSample ~= 0
                tb = obj.Result.values(obj.samplePoints(obj.pointChoice).idx,:);
            else
                tb = obj.Result.values([],:);
            end
        end
        
        function tb = get.resultsForThisPointNoNan(obj)
            tb = obj.Result.values(obj.samplePoints(obj.pointChoice).idx,:);
            OK = ~cellfun(@(x)isnumeric(x)&&isnan(x),table2cell(tb));
            tb = tb(:,OK);
        end
        
        function mask = get.selectionForThisPoint(obj)
            if obj.nearestSample == 0
                mask=[];
                return
            end
            tb = obj.resultsForThisPoint;
            if isempty(tb)
                mask=[];
                return; 
            end
            % evsel = obj.EventSelector;
            dists = obj.RawCatalog.epicentralDistanceTo(tb.y,tb.x);
            mask = dists <= tb.RadiusKm;
            nFoundEvents = sum(mask);
            if sum(mask) > tb.Number_of_Events
                msg.dbfprintf("<strong>Note:</strong>Selection doesn't exactly match results" + ...
                    " (<strong>%d</strong> found, expected <strong>%d</strong>)" + newline + ...
                    "  This happens when sampling requests N closest events," + newline + ...
                    "  but multiple events occur at same (farthest) distance\n",...
                    nFoundEvents, tb.Number_of_Events);
            end
            
        end
        
        function c = get.catalogForThisPoint(obj)
            c=obj.RawCatalog.subset(obj.selectionForThisPoint);
        end
        
        
        function save(obj, ~,~)
            co = class(obj);
            if any(co == '.')
                co=extractAfter(co, '.');
            end
            saveFileOptions = {...
                '*.csv','Results as a ASCII file';...
                '*.mat', [co ' object'];...
                '*.fig','Entire figure';...
                '*.fig','Result Axes only';...
                '*.mat','Results as a table';...
                '*.txt','X, Y, VAL ASCII table'};
            defaultSaveName = fullfile(ZmapGlobal.Data.Directories.output, co + "_results");
            [fn,pn,fmt] = uiputfile(...
                saveFileOptions,...
                'Save as', defaultSaveName);
            ff = fullfile(pn, fn);
            switch fmt
                case 1
                    writetable(obj.Result.Data, ff, 'FileType', 'text');
                case 2
                    save(ff,'obj');
                case 3
                    saveas(gcf, ff, 'fig');
                case 4
                    f = figure();
                    copyobj(obj.ax,f);
                    saveas(f,ff,'fig');
                    delete(f);
                case 5
                    myresults = obj.Data; %#ok<NASGU>
                    save(ff, 'myresults');
                case 6
                    minitable = table;
                    minitable.x = obj.Result.Data.x ;
                    minitable.y = obj.Result.Data.y ;
                    minitable.(obj.active_col) = obj.Result.Data.(obj.active_col);
                    writetable(minitable, ff, 'filetype', 'text');
                    
                otherwise
                    disp('do not yet know how to export to :');
            end
            
        end
    end % Public methods
    
    methods(Access=protected)
        
        function update(obj, varargin)
            obj.ResultDisplayer.update(varargin{:})
        end

    end % Protected methods
    

end
