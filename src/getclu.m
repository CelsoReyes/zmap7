% get the selected cluster

report_this_filefun(mfilename('fullpath'));

switch  gecl

    case 'mouse'
        disp(['Click with the left mouse button #next to the equivalent event #of the cluster you want to examine']);

        figure_w_normalized_uicontrolunits(clmap)
        [tmp2,tmp1]=ginput(1);

        x=tmp2;y=tmp1;

        l=sqrt(((equi(:,1)-x)*cos(pi/180*y)*111).^2 + ((equi(:,2)-y)*111).^2) ;
        [s,is] = sort(l);            % sort by distance
        new = equi(is(1),:);

        str = ['selected: Cluster # ' num2str(is(1)) ];
        set(te,'string',str);

        if ~exist('val0','var')
            val0 = 1;
        end
        j = findobj('tag',num2str(val0));
        try
            set(j,'MarkerSize',6,'Linewidth',1.0);
        catch ME
            error_handler(ME, @do_nothing);
        end

        val = is(1);

        j = findobj('tag',num2str(val));
        set(j,'MarkerSize',22,'Linewidth',4);


    case 'large'
        val = find(cluslength == max(cluslength));
end


l = clus == val;
newt2 = original(l,:);

if exist('tiplo') == 0; timeplot; end
nu = (1:newt2.Count) ;nu = nu';
set(tiplo2,'Xdata',newt2.Date,'Ydata',nu); figure_w_normalized_uicontrolunits(cum);


val0 = val;;
