function do_colorbar(obj,~,~)
    % used to override colorbar button
            if get(gcbf,'CurrentAxes')==findobj(obj.fig,'Tag','mainmap_ax')
                % do our thing
                h=findobj(gcf,'Type','colorbar','-and','Parent',obj.fig);
                if ~isempty(h)
                    delete(h)
                    return;
                end
                colorbar('peer',findobj(obj.fig,'Tag','mainmap_ax'),'EastOutside')
                h=findobj(gcf,'Type','colorbar','-and','Parent',obj.fig);
                h.Units='pixels';
                
                switch obj.colorField
                    
                    case 'Date'
                        h.TickLabels=datestr(h.Ticks,'yyyy-mm-dd');
                        h.Label.String='Date';
                        h.Direction='normal';
                    case 'Magnitude'
                        h.Label.String=obj.colorField;
                        h.TickLabels=string([h.Ticks]');
                        h.Direction='normal';
                    case 'Depth'
                        h.Label.String=obj.colorField;
                        h.TickLabels=string([h.Ticks]');
                        h.Direction='reverse';
                    otherwise
                        error('unanticipated colorfield')
                end
                        
            else
                eval(origCallback); % was a string at the time this was written
            end
        end