function create_projectedmap_from_mainmap(fig)
    m = findobj(fig,'Tag','main plots');
    m = findobj(m.SelectedTab,'Type','axes');
    
    ch=allchild(m);
    f=figure;
    ax=axes;
    axesm('lambert','MapLatLimit',m.YLim,'MapLonLimit',m.XLim);
    
    valid=["AlignVertexCenters"...
        "BusyAction"...
        ..."ButtonDownFcn"...
        "Color"...
        ..."CreateFcn"...
        ..."DeleteFcn"...
        "DisplayName"...
        "HandleVisibility"...
        "HitTest"...
        "Interruptible"...
        "LineJoin"...
        "LineStyle"...
        "LineWidth"...
        "Marker"...
        "MarkerEdgeAlpha"...
        "MarkerEdgeColor"...
        "MarkerFaceAlpha"...
        "MarkerFaceColor"...
        "MarkerIndices"...
        "MarkerSize"...
        "PickableParts"...
        "SelectionHighlight"...
        "Tag"...
        "UIContextMenu"...
        "UserData"...
        "Visible"...
        "Fill"...
        "LevelList"...
        "LabelSpacing"...
        "LevelStep"...
        "LevelStepMode"...
        "TextListMode"...
        "TextStep"...
        "TextStepMode"...
        ];
    
    
    hasContour=false;
    
    warnItem(1) = warning('off','MATLAB:structOnObject');
    warnItem(2) = warning('off','MATLAB:hg:EraseModeIgnored');
    
    for i=1:numel(ch)
        thisThing=ch(i);
        disp(thisThing);
        
        % there is likely a better way to transfer items values from the object that what is implemented here
        st = struct(thisThing);
        fn = fieldnames(st);
        st=rmfield(st, fn(~ismember(fn ,valid)));
        
        switch thisThing.Type
            case 'scatter'
                Y = thisThing.YData; X=thisThing.XData;
                X(isnan(Y)) = nan;
                Y(isnan(X)) = nan;
                if ~isempty(thisThing.ZData)
                    h=scatterm(Y, X, thisThing.SizeData, thisThing.CData,...
                        'ZData',thisThing.ZData);
                else
                    h=scatterm(Y, X, thisThing.SizeData, thisThing.CData);
                end
                if isfield(st,'Color');
                    st=rmfield(st,'Color');
                end
            case 'line'
                if ~isempty(thisThing.ZData)
                    h=linem(thisThing.YData, thisThing.XData, thisThing.ZData);
                else
                    h=linem(thisThing.YData, thisThing.XData);
                end
            case 'contour'
                hasContour=true;
                continue
            otherwise
                warning('ZMAP:projections:uncopiedType''did not copy a %s',thisThing.Type);
                continue
        end
        
        if isa(h,'matlab.graphics.primitive.Group')
            h=findobj(h,'Type','scatter','-or','Type','line');
        end
        
        set(h,st);
    end
    
    warning(warnItem(1).state,warnItem(1).identifier);
    warning(warnItem(2).state,warnItem(2).identifier);
    
    if hasContour
        % assume it came from the results.
        % TOFIX this doesn't ACTUALLY create a contour. stuck in older graphical library?
        t=ancestor(m,'uitab');
        v=t.UserData.Result.values;
        valid= ~isnan(v.x) & ~isnan(v.y);
        lat=linspace(m.YLim(1),m.YLim(2),200);
        lon=linspace(m.XLim(1),m.XLim(2),200)';
        vq = griddata(v.y(valid), v.x(valid), v.(t.UserData.active_col)(valid), lat, lon);
        if thisThing.Fill=="on"
           % h=contourfm(v.y(valid), v.x(valid), v.(t.UserData.active_col)(valid));
           contourfm(lat, lon, vq');
        else
           contourm(lat, lon, vq');
        end
        
    else
        if isa(h,'matlab.graphics.primitive.Group')
            h=findobj(h,'Type','scatter','-or','Type','line');
        end
        set(h,st);
    end
end