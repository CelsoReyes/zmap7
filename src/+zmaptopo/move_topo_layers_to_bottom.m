function move_topo_layers_to_bottom(container)
    h=findobj(container,'Type','surface','-and','-regexp','Tag','topographic_map_.*');
    p=unique([h.Parent]);
    for i=1:numel(p)
        idx=startsWith(get(p(i).Children,'Tag'),'topographic_map_');
        h=p(i).Children(idx);
        others=p(i).Children(~idx);
        p(i).Children=[others;h];
    end
        
end