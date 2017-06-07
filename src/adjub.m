report_this_filefun(mfilename('fullpath'));


prompt={'Enter the maximum radius cut-off:','Enter the minimum Utsu probability '};
def={'nan','nan'};
dlgTitle='Input Map Selection Criteria';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
re4 = re3;

l = answer{2,1}; tresh = str2num(l) ;
l = answer{1,1}; minpe = str2num(l) ;

if tresh >= 0
    l = Prmap < tresh;
    re3(l) = re3(l)*0+1;
elseif minpe >= 0
    l = r >= minpe;
    re3(l) = re3(l)*0+1;
end

ca = caxis;

ve = ca(1):(ca(2)-ca(1))/64:ca(2);

i = find(abs(ve-1) == min(abs(ve-1)) );

col = jet;
col(i,:) = [0.8 0.8 0.8] ;
col(i-1,:) = [0.8 0.8 0.8] ;
col(i+1,:) = [0.8 0.8 0.8] ;

colormap(col)


