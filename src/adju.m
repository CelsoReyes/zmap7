report_this_filefun(mfilename('fullpath'));


prompt={'Enter the minimum magnitude cut-off','Enter the maximum radius cut-off:','Enter the minimum goodness of fit percatge'};
def={'nan','nan','nan'};
dlgTitle='Input Map subselection Criteria';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
re4 = re3;
l = answer{1,1}; Mmin = str2num(l) ;
l = answer{2,1}; tresh = str2num(l) ;
l = answer{3,1}; minpe = str2num(l) ;

