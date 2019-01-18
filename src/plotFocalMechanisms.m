function plotFocalMechanisms(obj,ax,color)
    % PLOTFOCALMECHANISMS plot the focal mechanisms of a catalog (if they exist)
    % plotFocalMechanisms(catalog, ax, color)
    if ~exist(ax,'var') || ~isprop(ax,'type') || ax ~= "axes"
        ax=gca;
    end
    
    
    %pbar    = pbaspect(ax);
    pbar    = daspect(ax);
    asp     = pbar(1)/pbar(2);
    if isempty(obj.MomentTensor)
        warning('no moment tensors to plot');
    end
    axes(ax)
    set(gca, 'NextPlot', 'add');
    set(findobj(gcf,'Type','Legend'), 'AutoUpdate', 'off'); %
    h=gobjects(obj.Count,1);
    for i=1:obj.Count
        mt = obj.MomentTensor{i,:};
        if istable(mt)
            mt = mt{:,:};
        end
        
        if ~any(isnan(mt))
            h(i) = focalmech(mt,obj.Longitude(i),obj.Latitude(i),.05*obj.Magnitude(i),asp,color);
            set([h(i).circle(:);h(i).fill(:);h(i).text],'Tag','focalmech_');
            drawnow
            %TODO set the tag
        else
            disp('nan present in moment tensor')
        end
    end
    set(findobj(gcf,'Type','Legend'),'AutoUpdate','on')
end