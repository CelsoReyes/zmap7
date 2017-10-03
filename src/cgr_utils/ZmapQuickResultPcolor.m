function h=ZmapQuickResultPcolor(ax, res, choice, features)
    % ZmapQuickResultPcolor plots a pcolor map from a ZmapFunction
    % ax : axes to plot. empty is new figure.
    % res is the result from a ZmapFunction
    % choice : name of field in res.values table, or the number of that field.
    % features: which features to also plot (CELL of chararrays)
    %
    % eg. 
    %  h=ZmapQuickResultPcolor(gca,res,'b_value',{'borders','lakes'});
    %
    % do not plot onto the original axes unless you like messed up colors.
    %
    % SUPER COOL addition, if I don't say so myself. -CGR

    if istable(res.values)
        choices=res.values.Properties.VariableNames;
    end
    if ~exist('choice','var') || isempty(choice)
        disp('Possible plot choices for this variable are:')
        for i = 1 : numel(choices)
            fprintf('%d : ''%s\n''',i,choices{i});
        end
        return
    end
    if isnumeric(choice)
        choice=choices{choice};
    end
    if exist('features','var') && isempty(features)
        features={'borders'};
    end
    if isempty(ax)
        h=figure('Name',choice);
        ax=gca;
    else
        axis(ax);
        hold on;
    end
    pg = res.Grid.pcolor(ax, res.values.(choice), choice);
    % uistack(pg,'bottom');
    ZG = ZmapGlobal.Data;
    if isa(ZG,'ZmapData')
        shading(ZG.shading_style)
        hold on
        res.Grid.plot([],'color',[.5 .5 .5],'displayname','grid points','markersize',3);
        for j=1:numel(features)
            try
                ft=ZG.features(features{j});
                % newft=copyobj(ft,ax)
                ft.plot(ax); %TOFIX
            catch ME
                warning('couldn''t plot %s\n%s',features{j},ME.message);
            end
        end
    end
    mytitle= sprintf('GridName: "%s" , CatalogName "%s"',...
        res.Grid.Name,...
        res.InCatalogName{1});
    title(mytitle,'Interpreter','none');
    colorbar
    
end