function [uOutput] = scecdcimp(nFunction, sFilename)

% Filter function switchyard
if nFunction == 0     % Return info about filter
    uOutput = 'ASCII columns seperated by blanks or tabs';
elseif nFunction == 1 % Import and return catalog
    % Read formated data
    uOutput = load(sFilename); %check for 0 in day or month - set to 1
    % check fro months or days == 0
    l = uOutput(:,5) == 0; uOutput(l,5) = 1;
    l = uOutput(:,4) == 0; uOutput(l,4) = 1;

    uOutput(:,3) = decyear([uOutput(:,3) uOutput(:,4) uOutput(:,5) uOutput(:,8) uOutput(:,9)]);

end

