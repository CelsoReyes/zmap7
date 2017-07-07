%
% Window which allows to choose the dimension of the interevent distances, and the geometry of
% the embedding volume.
%
%
disp('fractal/codes/randfd.m');
%
%
prompt1 = {'Type in the dimension (2 or 3) in which the interevent distances should be calculated: ',...
    'Choose the geometry of the volume; for a rectangle type in 1, for a sphere type in 2'};
def1 = {'3','1'};
inpdlgtitle = 'Dimension and Volume';
lineNo = 2;
dim = inputdlg(prompt1, inpdlgtitle, lineNo, def1);
clear prompt1 def1 inpdlgtitle lineNo;

E = ran;    % Attributing the corresponding catalog to E

if dim{1} == '2'

    org = [1];
    dopairdist2;

elseif dim{1} == '3'

    if dim{2} == '1'

        org = [2];
        dopairdist3;

    else;

        fdsphere;

    end
end
