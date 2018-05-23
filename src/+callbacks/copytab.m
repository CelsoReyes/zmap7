function copytab(~,~)
    % COPYTAB copy the contents from a tab into a new figure
    assert(get(gco,'Type') == "uitab");
    thetab=gco;
    tocopy=thetab.Children;
    newfig = figure('Name',thetab.Title);
    copyobj(tocopy,newfig);
end