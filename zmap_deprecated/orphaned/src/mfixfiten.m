function f = mfixfiten(par)

    report_this_filefun(mfilename('fullpath'));

    global tdat ydat qdat pon maxen tf kf Aeq ratio mag con cor time rms span
    bound
    deltat = (par(1) - tdat);
    tfun = deltat.^pon ;
    Aeq=[tfun ones(size(ydat))];
    con = Aeq\ydat;
    zed = Aeq*con;
    f = norm(zed-ydat);
    cor = corrcoef(zed,ydat);
    maxen = con(2);
    rms = f/((length(ydat)).^0.5);
    ratio = rms./(max(ydat)-min(ydat));

    if bound == 14
        mag = (log10(2*(abs(maxen - max(ydat))))-kf(2))/kf(1);
    else
        mag = (log10(abs(maxen - max(ydat)))-kf(2))/kf(1);
    end
    tf = par(1);
    % Statements to plot progress of fitting:
    if pon>0.01
        plot(tdat,zed,tdat,ydat,'o',tf,maxen,'x')
    else
        plot(tdat,zed,tdat,ydat,'o')
    end
    text(.15,.82,['  tf = ' sprintf('%6.2f',(tf)) '   mfixed = '
        num2str(pon)],'sc')
    text(.15, .72,['  rms error / range = ' num2str(ratio)],'sc')
    text(.15, .67,['  con= ' num2str(con(1)) '    ' num2str(con(2))],'sc')
    if pon>0.01
        text(.15,.77,['  mag =  ' num2str(mag) '  corcoef = '
            num2str(cor(2,1))],'sc')
    else
        text(.15,.77,[' equivalent mag =  ' num2str(mag) '  corcoef = '
            num2str(cor(2,1))],'sc')
    end



