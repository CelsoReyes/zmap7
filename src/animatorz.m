
report_this_filefun(mfilename('fullpath'));

global ps1 ps2 plin pli

switch(action)
    case 'start'
        disp('waiting for button press')
        axis manual; hold on
        set(gcf,'Pointer','cross');
        waitforbuttonpress
        point1 = get(gca,'CurrentPoint'); % button down detected
        ps1 = plot(point1(1,1),point1(1,2),'ws');

        set(gcf,'WindowButtonMotionFcn',' action = ''move''; animatorz')
        set(gcf,'WindowButtonUpFcn','action = ''stop''; animatorz ')

        point2 = get(gca,'CurrentPoint');
        ps2 = plot(point2(1,1),point2(1,2),'w^','era','xor');
        plin = [point1(1,1) point1(1,2) ; point2(2,1) point2(2,2)];
        pli = plot(plin(:,1),plin(:,2),'w-','era','xor');
        set(pli,'LineWidth',2)

    case 'move'
        currPt=get(gca,'CurrentPoint');
        set(ps2,'XData',currPt(1,1))
        set(ps2,'YData',currPt(1,2))
        set(pli,'XData',[ plin(1,1) currPt(1,1)]);
        set(pli,'YData',[ plin(1,2) currPt(1,2)]);

    case 'stop'
        set(gcf,'Pointer','arrow');
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        slm = 'newslice'; slicemapz

end


