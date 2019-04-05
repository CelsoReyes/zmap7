function copytab(~,~)
    % COPYTAB copy the contents from a tab into a new figure
    thetab = ancestor(gco,'uitab');
    tocopy=thetab.Children;
    newfig = figure('Name',thetab.Title);
    copyobj(tocopy,newfig);
end