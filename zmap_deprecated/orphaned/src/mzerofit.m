function f = mzerofit(par)

    report_this_filefun(mfilename('fullpath'));

    global next Mw tdat ydat qdat pon maxen tf kf Aeq ratio mag con con2lo cor
    time rms bound
    deltat = par(1) - tdat;
    tfun = (log10(deltat));
    Aeq=[tfun ones(size(ydat))];
    con = Aeq\ydat;
    con(1)=1.0;
    zed = Aeq*con;
    f = norm(zed-ydat);
    rms = f/((length(ydat)).^0.5);
    ratio = rms./(max(ydat)-min(ydat));
    cor = corrcoef(zed,ydat);
    maxen = con(2);
    if bound == 14
        mag = (log10(2*(abs(maxen - max(ydat))))-kf(2))/kf(1);
    else
        mag = (log10(abs(maxen - max(ydat)))-kf(2))/kf(1);
    end
    tf =  par(1);
    % Statements to plot progress of fitting:
    plot(tdat,zed,tdat,ydat,'o')
    xt = min(tdat);
    y1t = min(ydat) + 0.9*(max(ydat)-min(ydat));
    y2t = min(ydat) + 0.8*(max(ydat)-min(ydat));
    y3t = min(ydat) + 0.7*(max(ydat)-min(ydat));
    y4t = min(ydat) + 0.6*(max(ydat)-min(ydat));
    text(xt,y1t,[' tf = ' sprintf('%6.2f',(tf)) '  use log for m= 0'])
    text(xt, y2t,['   rms error / range = ' num2str(ratio)])
    text(xt, y3t,[' con= ' num2str(con(1)) '  ' num2str(con(2))])
    text(xt, y4t,[' mag = indeterminate   ' ])


