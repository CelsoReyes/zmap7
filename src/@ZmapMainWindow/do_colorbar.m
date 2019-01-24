function do_colorbar(obj,src,evt,origCallback)
    % DO_COLORBAR used to override colorbar button
    % do_colorbar(obj,src,evt,origCallback)
    
    if get(gcbf,'CurrentAxes')==findobj(obj.fig,'Tag','mainmap_ax') || (exist('src','var') && isequal(src,obj.map_axes))
        % do our thing
        h=findobj(obj.fig,'Type','colorbar','-and','Parent',obj.fig);
        if ~isempty(h) || obj.colorField == "-none-"
            delete(h)
            return;
        end
        colorbar('peer',findobj(obj.fig,'Tag','mainmap_ax'),...
            'manual','Units','normalized','Position',determineColorbarPosition(),...
            'Tag','mainmap_colorbar')
        h=findobj(obj.fig,'Type','colorbar','-and','Parent',obj.fig);
        h.Units='normalized';
        
        switch obj.colorField
            
            case 'Date'
                h.TickLabels=datestr(h.Ticks,'yyyy-mm-dd');
                h.Label.String='Date';
                h.Direction='normal';
            case 'Depth'
                h.Label.String=obj.colorField;
                h.TickLabels=string([h.Ticks]');
                h.Direction='reverse';
            otherwise
                h.Label.String=obj.colorField;
                h.TickLabels=string([h.Ticks]');
                h.Direction='normal';
        end
        
    else
        % callbacks could be of several forms. It could be a
        if ~exist('origCallback','var') || isempty(origCallback)
            % do nothing
        elseif isa(origCallback,'function_handle')
            origCallback(src,evt)
        elseif iscell(origCallback)
            fn=origCallback{1};
            fn(src,ev,origCallback{2:end});
        elseif ischar(origCallback)
            eval(origCallback); % was a string at the time this was written
        end
    end
    
    function lbwh = determineColorbarPosition()
        % 
        % created because the colorbar gets repositioned strangely, covered by the UL and LR 
        % elements.;
        switch obj.xsgroup.Visible
            case 'on'
                lbwh=obj.MapCBPos_S;
               
            case 'off'
                lbwh=obj.MapCBPos_L;
        end
    end
end


