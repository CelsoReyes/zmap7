% tHis subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactiVELY. The bvalue in each
% volume around a grid point containing ni earthquakes
% will be calculated as well as the magnitude
% of completness
%   Stefan Wiemer 1/95

report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

% get the grid parameter
% initial values
%
dd = 1.00;
dx = 1.00 ;
ni = 300;


figure_w_normalized_uicontrolunits(xsec_fig)
hold on

x = [];
y = [];
hold on

x = gxd;
y = gyd;

%create a rectangular grid
xvect=x;
yvect=y;
gx = xvect;gy = yvect;
tmpgri=zeros((length(xvect)*length(yvect)),2);
slv=zeros((length(xvect)*length(yvect)),1);
n=0;
for i=1:length(xvect)
    for j=1:length(yvect)
        n=n+1;
        tmpgri(n,:)=[xvect(i) yvect(j)];
        slv(n) = sl(j,i);
    end
end

newgri = tmpgri;

% Plot all grid points
plot(newgri(:,1),newgri(:,2),'+k')

if length(xvect) < 2  ||  length(yvect) < 2
    errordlg('Selection too small! (not a matrix)');
    return
end

itotal = length(newgri(:,1));

zmap_message_center.set_info(' ','Running... ');think
%  make grid, calculate start- endtime etc.  ...
%
t0b = newa(1,3)  ;
n = length(newa(:,1));
teb = newa(n,3) ;
tdiff = round((teb - t0b)*365/par1);
loc = zeros(3,length(gx)*length(gy));

% loop over  all points
%
i2 = 0.;
i1 = 0.;
bvg = [];
allcount = 0.;
wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','p-value grid - percent done');;
drawnow
%
% loop


%
for i= 1:length(newgri(:,1))
    x = newgri(i,1);y = newgri(i,2);
    allcount = allcount + 1.;
    i2 = i2+1;

    % calculate distance from center point and sort wrt distance
    l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
    [s,is] = sort(l);
    b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

    % take first ni points
    b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
    l2 = sort(l); di = l2(ni);

    [st,ist] = sort(b);   % re-sort wrt time for cumulative count
    b = b(ist(:,3),:);

    % call the p-value function
    ttcat = b;
    [p,sdp] = mypval(3,mati);
    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
    bvg = [bvg ; p sdp x y di bv slv(i) ];
    %waitbar(allcount/itotal)
    (allcount/itotal)
end  % for  newgri

% save data
%
%  set(txt1,'String', 'Saving data...')
drawnow
gx = xvect;gy = yvect;

catSave3 =...
    [ 'zmap_message_center.set_info(''Save Grid'',''  '');think;',...
    '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
    ' sapa2 = [''save '' path1 file1 '' ll tmpgri bvg xvect yvect gx gy ni dx dd par1 ni newa maex maey maix maiy ''];',...
    ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

close(wai)
watchoff

% reshape a few matrices
%
normlap2=ones(length(tmpgri(:,1)),1)*nan;
normlap2(:)= bvg(:,1);
re3=reshape(normlap2,length(yvect),length(xvect));

normlap2(:)= bvg(:,2);
old1 =reshape(normlap2,length(yvect),length(xvect));

normlap2(:)= bvg(:,5);
r=reshape(normlap2,length(yvect),length(xvect));

normlap2(:)= bvg(:,6);
bv=reshape(normlap2,length(yvect),length(xvect));

normlap2(:)= bvg(:,7);
sl2=reshape(normlap2,length(yvect),length(xvect));

old = re3;

% View the b-value map
view_pv2

