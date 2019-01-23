classdef MemorizedCatalogManager<handle
    % MEMORIZEDCATALOGMANAGER handles the memorization and recall of catalogs
    % basic Functionality:
    %    memorize(catalog)
    %    catalog = recall()
    %    remove()
    %    This memorizes your catalog as 'default'
    %
    %    Multiple catalogs can be specified if a name is provided.  eg. to memorize as 'other'
    %       memorize(catalog,'other')
    %       catalog = recall('other')
    %       remove('other')
    
    properties(Constant)
        MemorizedCatalogs = containers.Map();
    end
    
    methods
        function memorize(obj,catalog, name)
            if ~exist('name','var')
                name = 'default';
            end
            assert(isa(catalog,'ZmapBaseCatalog'));
            obj.MemorizedCatalogs(name) = copy(catalog); %must be copied, otherwise it will change
        end
        
        function catalog = recall(obj, name)
            if ~exist('name','var')
                name = 'default';
            end
            catalog = copy(obj.MemorizedCatalogs(name));
        end
        
        function remove(obj,name)
            if ~exist('name','var')
                name = 'default';
            end
            obj.MemorizedCatalogs.remove(name);
        end
        
        function s = list(obj)
            s = obj.MemorizedCatalogs.keys;
        end
        
        function tf = isempty(obj)
            tf = isempty(obj.MemorizedCatalogs);
        end
        
        function s=info(obj, name)
            if ~exist('name','var')
                name = 'default';
            end
            tmp=obj.MemorizedCatalogs(name); % do not recall, or a copy will be made
            fmtstr = '"%s" %d events, mag %.1f to %.1f, start: %s';
            if nargout==0
                fprintf(fmtstr+"\n",tmp.Name, tmp.Count, min(tmp.Magnitude), max(tmp.Magnitude), string(min(tmp.Date)));
            else
                s = sprintf(fmtstr,tmp.Name, tmp.Count, min(tmp.Magnitude), max(tmp.Magnitude), string(min(tmp.Date)));
            end
        end
        
        function disp(obj)
            fprintf('<a href="matlab:helpPopup MemorizedCatalogManager">MemorizedCatalogManager</a> containing');
            switch length(obj.MemorizedCatalogs)
                case 0
                    fprintf(' nothing (empty)\n')
                case 1
                    if obj.list == "default"
                        fprintf(':\n   %s\n',obj.info('default'));
                    else
                        k = obj.MemorizedCatalogs.keys;
                        fprintf(':\n   [%s] \t%s\n',k{1}, obj.info(k{1}));
                    end
                otherwise
                    l = obj.list();
                    fprintf(' %d catalogs:\n', numel(l));
                    for i=1:numel(l)
                        fprintf('   [%s] \t%s\n',l{i}, obj.info(l{i}));
                    end
                    disp('');
            end
        end
    end
    
end
    