classdef MouseBehaviors<handle
    % MOUSEBEHAVIORS one-stop location for changing the mouse behaviors for figures 
    
    methods(Static)
        function zoom_scroll(fig, factor)
            % ZOOMSCROLL adjust grid spacing when mouse wheel is scrolled
            % zoom_scroll(fig,[]) zooms in and out on the current access with a 1.05 factor.
            %
            % zoom_scroll(fig, factor) zooms in and out with a specified factor. if
            % factor is a scalar, then both X & Y are scaled the same. otherwise, provide
            % a pair of scroll factors [XFACTOR YFACTOR].
            % 
            % ex.  zoom vertically only: 
            %   Behaviors.zoom_scroll(gcf, [1 1.05];
            
            if ~exist('factor','var') 
                factor=[1.05 1.05];
            elseif numel(factor) == 1
                factor=[factor factor];
            end
            assert( ~any(factor==0), 'Zero is not allowed to be a zoom factor.  To avoid zooming, use a value of 1');
                
            fig.WindowScrollWheelFcn = @zoom_scale;
            
            function zoom_scale(~,ev)
                center.X=mean(xlim);
                center.Y=mean(ylim);
        
                if ev.VerticalScrollCount > 0
                    xlim(fig.CurrentAxes, (xlim-center.X) .* factor(1) + center.X);
                    ylim(fig.CurrentAxes, (ylim-center.Y) .* factor(2) + center.Y);
                elseif ev.VerticalScrollCount < 0
                    xlim(fig.CurrentAxes, (xlim-center.X) ./ factor(1) + center.X);
                    ylim(fig.CurrentAxes, (ylim-center.Y) ./ factor(2) + center.Y);
                end
            end
        end
        
    end
end