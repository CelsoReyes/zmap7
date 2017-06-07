function newcat = excludequarries(orgcatalog,quarries)
    %this function searches with ismember every quarry defined with 'quarries'
    %(typical the variable q) in the orgcatalog (typical a) and removes
    %them in the original catalog.


    foundquars=ismember(orgcatalog,quarries,'rows');

    newcat=orgcatalog(~foundquars,:);



end
