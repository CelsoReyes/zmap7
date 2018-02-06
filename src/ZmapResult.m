classdef ZmapResult
    %ZMAPRESULT Summary of this class goes here
    %   Detailed explanation goes here
    %
    %
    % resultMatrix contains
    %   
    properties
        resultMatrix
    end
    
    methods
        function obj=ZmapResult(resultMatrix)
        end
        
        function plot(obj,varargin)
            % plots the results on the provided axes.
            
            f=findobj(groot,'Tag',obj.PlotTag,'-and','Type','figure');
            if isempty(f)
                f=figure('Tag',obj.PlotTag);
            end
            figure(f);
            set(f,'name','B-values')
            delete(findobj(f,'Type','axes'));
            
            obj.Grid.pcolor([],obj.Result.values.b_value,'B-values');
            shading(obj.ZG.shading_style);
            hold on
            obj.Grid.plot();
            ft=obj.ZG.features('borders');
            copyobj(ft,gca);
            colorbar
            title('B-values')
            xlabel('Longitude')
            ylabel('Latitude')
            
            %TODO add shading menu
            %TODO add plotAnyValue menu that 
            
           % plot here
        end
    end
    
end

