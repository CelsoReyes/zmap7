classdef SynthTypes < int32
    % enumeration associated with synthetic catalog for declustering
    enumeration
        none (0)
        background_rate (1)
        etas (2)
    end
    
    methods(Static)
        function s = description(st)
            switch st
                case SynthTypes.none
                   s = "no synthetic catalog";
                case SynthTypes.background_rate
                   s = "synthetic catalog only background rate"
                case SynthTypes.etas
                   s = "synthetic catalog with ETAS"
            end
        end
    end
end