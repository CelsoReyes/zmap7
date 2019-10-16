classdef (ConstructOnLoad, Sealed) MomentTensorAddon < ZmapCatalogAddon
    %   MomentTensorAddon for a ZmapCatalog
    %   Dip - angle of dip
    %   DipDirection - direction of dip
    %   Rake - direction of movement for hanging wall block
    %
    %   MomentTensor - table, as mrr, mtt, mff, mrt, mrf, mtf
    %               r : up , t: south, f or p:east
    
    properties(Constant)
        Type = 'MomentTensor' % unique name used when querying catalog
    end
    properties
        Dip  (:,1)           double      % angle of dip, between 0 (horiz) and 90 degrees (vert)
        DipDirection (:,1)    double      % direction of dip (clockwise from north
        Rake (:,1)          double      % direction of movement for hanging wall block
        MomentTensor    table       = get_empty_moment_tensor() % moment tensor information
    end
       
    properties(Dependent, Transient)
        mrr % radial-radial aka up-up
        mtt % theta-theta aka north-north
        mff % phi-phi aka east-east
        mrt % radial-theta aka up-south
        mrf % radial-phi aka up-east
        mtf % theta-phi aka south-east
        
    end
    
    properties(Dependent, Hidden, Transient)
        mpp % phi-phi aka east-east
        mrp % radial-phi aka up-east
        mtp % theta-phi aka south-east
        
        mzz % down-down
        mnn % north-north
        mee % east-east
        mnz % north-down
        mez % east-down    (-mrf)
        mne % north-east   (-mtf)
    end
        
    
    methods

        function obj = MomentTensorAddon(value)
            obj@ZmapCatalogAddon;
            if ~exist('value','var')
                return
            end
            %
            
            MomentTensorColumns = {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'};
            %{
            Two possible coordinate systems could be in use.
                r-theta-phi         translates to    up - south - east
                    Note: "phi" can be represented by 'f' or 'p'
                n-e-z               translates to   north - east - down
            so:
                mrr == mzz , mrt == mnz , mtt == mnn ,  mrp = -mez , mff == mee , mtf == -mne
            %}
            
            if istable(value)
                assert(isequal(value.Properties.VariableNames,MomentTensorColumns));
                obj.MomentTensor = value;
            elseif isnumeric(value)
                assert(size(value,2) == 6,...
                    'expect moment tensors to have 6 columns %s:', strjoin(MomentTensorColumns,', '));
                obj.MomentTensor     = array2table(value, 'VariableNames', MomentTensorColumns);
            end
        end

        function outval = ZmapArrayColumns(obj)
            % ZMAPARRAY create a zmap array from this catalog
            % zmarr = catalog.ZMAPARRAY()
            outval = [...
                obj.Dip(:),... 
                obj.DipDirection(:),... 
                obj.Rake(:)...
            ];
        end        
        
        
        
        function v=get.mrr(obj); v = obj.MomentTensor.mrr; end
        function v=get.mzz(obj); v = obj.MomentTensor.mrr; end
        
        function v=get.mtt(obj); v = obj.MomentTensor.mtt; end
        function v=get.mnn(obj); v = obj.MomentTensor.mtt; end
        
        function v=get.mff(obj); v = obj.MomentTensor.mff; end
        function v=get.mpp(obj); v = obj.MomentTensor.mff; end
        function v=get.mee(obj); v = obj.MomentTensor.mff; end
        
        function v=get.mrt(obj); v = obj.MomentTensor.mrt; end
        function v=get.mnz(obj); v = obj.MomentTensor.mrt; end
        
        
        function v=get.mrp(obj); v = obj.MomentTensor.mrf; end
        function v=get.mrf(obj); v = obj.MomentTensor.mrf; end
        function v=get.mez(obj); v = -obj.MomentTensor.mrf; end
                
        function v=get.mtf(obj); v = obj.MomentTensor.mtf; end
        function v=get.mtp(obj); v = obj.MomentTensor.mtf; end
        function v=get.mne(obj); v = -obj.MomentTensor.mtf; end
    end
    
    methods(Static)
        function obj = blank()
            % allows subclass-aware use of empty objects
            obj = ZmapCatalog();
        end
        
    end
    methods (Static, Hidden)
        
        % % % intentionally not implementing: fields_that_must_be_nevent_length(); 
        function s = display_order()
            s = {'Dip','DipDirection','Rake','MomentTensor'};
        end
        
        function pef = possibly_empty_fields()
            % fields that are either empty, or have the same length as event.
            pef = {'Dip','DipDirection','Rake', 'MomentTensor'};
        end

    end
end

function tb = get_empty_moment_tensor()
    tb = table([],[],[],[],[],[],'VariableNames', {'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'});
end
