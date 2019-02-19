function plotFocalMechanisms(catalog,ax,color)
    % PLOTFOCALMECHANISMS plot the focal mechanisms of a catalog (if they exist)
    % plotFocalMechanisms(catalog, ax, color)
    if ~exist('ax','var') || ~isprop(ax,'type') || ax ~= "axes"
        ax = gca;
    end
    
    
    %pbar  = pbaspect(ax);
    pbar    = daspect(ax);
    asp     = pbar(1)/pbar(2);
    if ~catalog.hasAddon('MomentTensor')
        warning('catalog has  no moment tensors to plot');
        return
    end
    axes(ax)
    set(gca, 'NextPlot', 'add');
    set(findobj(gcf,'Type','Legend'), 'AutoUpdate', 'off'); %
    h = {}%gobjects(catalog.Count,1);
    mts = catalog.getAddon('MomentTensor');
    for i=1:catalog.Count
        mt = [mts.mrr(i), mts.mtt(i), mts.mff(i), mts.mrt(i), mts.mrf(i), mts.mtf(i)];
        
        if ~any(isnan(mt))
            hh = focalmech(mt, catalog.Longitude(i),catalog.Latitude(i),.05*catalog.Magnitude(i),asp,color);
            set([hh.circle(:); hh.fill(:); hh.text],'Tag','focalmech_');
            h(i) = {hh};
            drawnow limitrate nocallbacks
            %TODO set the tag
        else
            disp('nan present in moment tensor')
        end
    end
    set(findobj(gcf,'Type','Legend'),'AutoUpdate','on')
end