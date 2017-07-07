function f = ttofit(par)

    report_this_filefun(mfilename('fullpath'));

    global next Mw tdat ydat qdat pon maxen tf kf Aeq ratio mag con cor time rms bound
    deltat = (par(1) - tdat);
    tfun = ((deltat).^(par(2)));
    Aeq=[tfun ones(size(ydat))];
    % nydat= (ydat-mean(ydat))./std(ydat);
    con = Aeq\ydat;
    zed = Aeq*con;
    f = norm(zed-ydat);
    rms = f/((length(ydat)).^0.5);
    ratio = rms./(max(ydat)-min(ydat));
    cor = corrcoef(zed,ydat);
    maxen = con(2);
    if kf(1) < 0.001
        mag = NaN;
    elseif bound == 14
        mag = (log10(2*(abs(maxen - max(ydat))))-kf(2))/kf(1);
    else
        mag = (log10(abs(maxen - max(ydat)))-kf(2))/kf(1);
    end
    tf = par(1) ;

    % Statements to plot progress of fitting:
    %  if par(2)>0.01
    %    plot(tdat,zed,tdat,ydat,'ow',tf,maxen, 'x')
    %    vert = abs(maxen- min(ydat));
    %  else
    plot(tdat,zed,tdat,ydat,'go')
    %  end

    text(0.15,0.82,[' tf = ' sprintf('%6.2f',(tf)) '   m =  ' num2str(par(2))],'sc')
    text(0.15, 0.67,[' rms error/ range = ' num2str(ratio)],'sc')
    if par(2)>0.01
        text(0.15,0.77,[' mag =  ' num2str(mag)],'sc')
        text(0.15,0.72,['  corcoef = ' num2str(cor(2,1))],'sc')
    else
        text(0.15,0.77,[' equivalent mag = ' num2str(mag)],'sc')
        text(0.15,0.72,[' corcoef = ' num2str(cor(2,1))],'sc')
    end
    text(0.15, 0.62,[' c= ' num2str(con(1)) '   ' num2str(con(2))],'sc')



