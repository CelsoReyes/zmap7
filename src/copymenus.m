function copymenus(H,P)
    %copymenus Make copies of menu items with children. 

    copyobj(H,P);
    submenus = allchild(P);
    me=submenus(1);
    assert(me.Text == string(H.Text));
    ch  = findall(me);
    oth = findall(H);
    
    % synchronize the callbacks by copying
    for j=1:numel(ch)
        ch(j).MenuSelectedFcn = oth(j).MenuSelectedFcn;
    end
end