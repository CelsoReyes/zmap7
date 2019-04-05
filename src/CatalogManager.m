classdef CatalogManager < handle
    % Manage a bunch of catalogs, filtering according to each catalog's associated filter function as needed
    properties
        RawCatalog % this is the catalog that will be filtered
    end
    
    properties(Access=private)
        Catalogs        containers.Map
    end
    
    events
        RawCatalogChanged
    end
    
    methods
        function obj = CatalogManager(catalog)
            obj.RawCatalog = catalog;
        end
        
        function AddSubset(obj, Tag, filterFcn, whoToNotify)
            subcatalog.FilterFcn = filterFcn; % filterFcn returns a logical mask
            subcatalog.Filter = subcatalog.FilterFcn(obj.RawCatalog);
            if ismember(Tag, keys(obj.Catalogs))
                error('%s is already being used. Did you mean to CHANGE the filter instead?',Tag)
            end
            obj.Catalogs(Tag) = subcatalog;
        end
        
        function catalog = GetSubset(obj, Tag)
            subcatalog = obj.Catalogs(Tag);
            if numel(subcatalog.Filter) ~= obj.RawCatalog.Count
                subcatalog.Filter = subcatalog.FilterFcn(obj.RawCatalog);
            end
            catalog = obj.RawCatalog.subset(subcatalog.Filter);
        end
        
        function filt = GetFilter(obj, Tag, position)
            % position can be 'first' or 'last' or empty (empty returns all)
            subcatalog = obj.Catalogs(Tag);
            if numel(subcatalog.Filter) ~= obj.RawCatalog.Count
                subcatalog.Filter = subcatalog.FilterFcn(obj.RawCatalog);
            end
            filt = subcatalog.Filter;
            if exist('position','var')
            	p = find(filt, 1, position);
                filt = false(size(filt));
                filt(p) = true;
            end
        end
        
        function ChangeFilter(obj, Tag, filterFcn)
            subcatalog.FilterFcn = filterFcn; % filterFcn returns a logical mask
            subcatalog.Filter = subcatalog.FilterFcn(obj.RawCatalog);
            obj.Catalogs(Tag) = subcatalog;
        end
        
        function RemoveSubset(obj, Tag)
            remove(obj.Catalogs,Tag);
        end
        
        function RecalculateFilter(obj, Tag)
            subcatalog = obj.Catalogs(Tag);
            subcatalog.Filter = subcatalog.FilterFcn(obj.RawCatalog);
            obj.Catalogs(Tag) = subcatalog;
        end
        
        function recalculateAllFilters(obj)
            for key = keys(obj.Catalogs)
                obj.Recalculate(key{1});
            end
        end
        
        function disp(obj)
            getIndentedSummary = @(ca,level) "     "+ strrep(summary(ca,level),newline,[newline, '       ']);
            disp('CatalogManger with:')
            disp('  <strong>RawCatalog</strong>:')
            disp(getIndentedSummary(obj.RawCatalog,'simple'));
            fprintf('\n\nWith Tagged entries:\n')
            for key = keys(obj.Catalogs)
                Tag = key{1};
                c = obj.GetSubset(Tag);
                entry = obj.Catalogs(Tag);
                fprintf("  <strong>%-10s</strong> : %s  yielding\n","'"+Tag+"'", func2str(entry.FilterFcn));
                disp(getIndentedSummary(c,'simple'));
                fprintf('\n\n');
            end
        end
    end
end