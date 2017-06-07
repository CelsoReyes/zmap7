report_this_filefun(mfilename('fullpath'));

j = 0;
it = 20
minval = minval*365/par1;
maxval = maxval*365/par1;
[len, ncu] = size(cumuall);
len = len -2;
step = nustep;


%set up movie axes
%
cin_lta
axes(h1)
fs = get(gcf,'pos');

m = moviein(length(1:step:len-iwl));

ma = [];
mi = [];


wai = waitbar(0,'Please wait...')
set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Movie -Percent done');
pause(0.1)

for it = minval:step:maxval
    j = j+1;
    cin_maxz
    axes(h1)
    m(:,j) = getframe(h1);
    figure_w_normalized_uicontrolunits(wai)
    waitbar(it/len)
end   % for i

close(wai)

% save movie
%
clear newmatfile

[newmatfile, newpath] = uiputfile('*.mat', 'Save As');

if length(newpath > 1)
    save([newpath newmatfile])
    showmovi
else
    showmovi
end

