classdef XSectionManager < handle
    % XSECTIONMANAGER manage cross sections
    % 
    %   manages the XSection class, making them available to all
    %
    
    properties(SetObservable)
        data = containers.Map()% contains struct detailing cross-sections
    end
    
    properties(Dependent)
        names
        Count
    end
    
    methods
        function attachListener(obj)
            addlistener(obj,'data','PostSet',@XSectionManager.propChange);
        function attachListener(obj)
            addlistener(obj,'data','PreSet',@XSectionManager.propChange);
        end
        function obj = XSectionManager()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        function xs = xsection(key)
            if obj.data.iskey(key)
                xs=obj.data(key).xsec;
            else
                xs=[];
            end
        end
        function xs = catalog(key)
            if obj.data.iskey(key)
                xs=obj.data(key).xsec;
            else
                xs=[];
            end
        end
        function xs = catinfo(key)
            if obj.data.iskey(key)
                xs=obj.data(key).summary;
            else
                xs=[];
            end
        end
        
        function tf=isempty(obj)
            tf=isempty(obj.xsections);
        end
        
        function c = get.Count(obj)
            c = numel(obj.data.keys);
        end
            
        function s = get.names(obj)
            s=obj.xsections.keys;
        end
        
        function gr = grid(obj,name, x_km, zs_km)
            gr = obj.xsections(name).getGrid(x_km, zs_km);
        end
        
        function disp(obj)
            k=obj.data.keys;
            if isempty(k)
                disp('empty xsec manager');
            end
            for i=1:numel(k)
                disp(obj.data(k{i}));
            end
        end
        
        function xs = choose(obj)
            disp('choose a cross section')
        end
            
        function change_color(obj,key, color)
            
        end
           
        
        function xsec_remove(obj, key)
            % XSEC_REMOVE completely removes cross section from object
            obj.data.remove(key);
            % send message when obj.data is empty
        end
        
        function xsec_add(obj, key, xsec, catalog)
            obj.data(key) = struct(...
                'xsec',xsec,...
                'catalog',catalog,...
                'catsummary',catalog.summary(stats));
            % send message when obj.data is changed
        end
        
    end
    
    methods(Static)
        function propChange(metaProp, eventData)
            h=eventData.AffectedObject;
            propName=metaProp.Name;
         disp(['The ',propName,' property has changed.'])
         disp(['The new value is: ',num2str(h.data)])
         disp(['Its default value is: ',num2str(metaProp.DefaultValue)])
        end
    end
            
end

