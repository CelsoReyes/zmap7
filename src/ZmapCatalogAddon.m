classdef ZmapCatalogAddon < matlab.mixin.Copyable
    % ZMAPCATALOGADDON is a base class for add-ons to a zmap catalog. FOr exaample, Moment Tensors
    properties(Abstract, Constant)
        Type
    end
    
    methods 
        
        function subsetInPlace(obj, idx)
            pef = obj.possibly_empty_fields();
            for ii =1: numel(pef)
                fn = pef{ii};
                if ~isempty(obj.(fn))
                    obj.(fn) = obj.(fn)(idx,:);
                end
            end
        end
        
        function newobj = subset(obj, idx)
            newobj=copy(obj);
            newobj.subsetInPlace(idx)
        end
        
        function disp(obj)
            if numel(obj)>1
                disp(obj.Type);
                return
            end
            disp("   "+ obj.Type + "  with properties:");
            
            show_categorical = @(f) {numel(categories(obj.(f))), get_limited_categories(obj.(f))};
            show_logical = @(f) {sum(obj.(f)), numel(obj.(f))};
            show_cell    = @(f) {strjoin(num2str(size(obj.(f))),'x')};
            show_simple  = @(f) {obj.(f)};
            show_range   = @(f) {min(obj.(f)), max(obj.(f))};
            show_refellipse=@(f) {obj.(f).Name, obj.(f).LengthUnit};
            show_table   = @(f) {height(obj.(f)), width(obj.(f)), strjoin(obj.(f).Properties.VariableNames,', ')};
            
            business = { ... classname , dispformat, dispfun
                "categorical"   , '%d categories [ %s ]'        , show_categorical;...
                "logical"       , '<logical> [%d of %d are true]' , show_logical;...
                "cell"          , '<%s cell>'                   , show_cell;...
                "char"          , '''%s'''                      , show_simple;...
                "string"        , '''%s'''                      , show_simple;...
                "datetime"      , {'%s', '[ %s  to  %s ]'}      , {show_simple, show_range};...
                "duration"      , {'%s', '[ %s  to  %s ]'}      , {show_simple, show_range};...
                "referenceEllipsoid" , '%s [Units:%s]'          , show_refellipse;...
                "table"         , '<table> with %d rows & %d cols: [%s]'     , show_table;...
                ""              , {'%g', '[ %g  to  %g ]'}      , {show_simple, show_range}...
                };
            
            p = obj.display_order();
            for i = 1:numel(p)
                pn = p{i};
                logic = business(class(obj.(pn))==[business{:,1}], :);
                if isempty(logic)
                    logic = business(end,:);
                end
                fn = logic{3};
                fmtstr = logic{2};
                if iscell(logic{2})
                    if numel(obj.(pn)) > 1
                        fmtstr = fmtstr{2};
                        fn = fn{2};
                    else
                        fmtstr = fmtstr{1};
                        fn = fn{1};
                    end
                end
                
                try
                    values = fn(pn);
                catch
                    if isempty(obj.(pn))
                        fmtstr = 'empty <%s>';
                    else
                        fmtstr = '<%s>';
                    end
                    values = class(obj.(pn));
                end
                fmtstr = "\t%20s : " + fmtstr + "\n";
                
                fprintf(fmtstr, pn, values{:});
            end
            
        end
        
    end
    methods (Abstract, Static, Hidden)
    	pef = possibly_empty_fields()
        s = display_order()
    end
end