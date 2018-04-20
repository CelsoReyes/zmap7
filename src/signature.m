function  th = signature(name,logo,pos,fontsize,offset)
    
    % SIGNATURE  Produces a "signature" with author's name and
    %         creation time at the specified position of a figure.
    %     SIGNATURE(NAME,LOGO,POS,FONTSIZE,OFFSET)
    %         creates 2 text objects:
    %         the first containing the NAME string and the creation
    %         time, and puts it into a specified position POS of
    %         the figure; the second - containing a string LOGO
    %         which is put just below the first text or at the
    %         position specified by a second row of POS.
    %         The fontsizes of the texts can be also specified by
    %         FONTSIZE argument (one or two numbers).
    %         OFFSET specify the relative distance between two lines
    %         of text.
    %         All input arguments are optional, but must be input in
    %         the given order. If some or all arguments are not
    %         specified, the default values are entered.
    %         Additional properties can be specified within the program:
    %         ISHM - (1 or 0) if hours:minutes to be added to date;
    %         COLOR -  color of the text;
    %         FTNAME - fontname.
    %    TH = SIGNATURE ... also returns handle(s) of the created
    %         text object(s).
    
    %  Kirill K. Pankratov,   kirill@plume.mit.edu
    %  April 8, 1994;  April 27, 1994
    
    report_this_filefun();
    
    % Defaults and setup ........................................
    namedflt = 'MyPlot';   % Name default
    logodflt = '';         % "Logo" default
    posdflt = [.65 .055];  % (Normalized) position default
    ftszdflt = 10;         % Font size default
    offsetdflt = .75;      % Space between the first and the second line
    
    ishm = 1;              % Is hours and minutes to be added to date
    color = [1 1 1];       % Color of the text
    ftname = 'helvetica';  % Fontname
    
    % Handle input ..............................................
    if nargin<5, offset = offsetdflt; end
    if nargin<4, fontsize = ftszdflt; end
    if nargin<3, pos = posdflt; end
    if nargin<2, logo = logodflt; end
    if nargin<1, name = namedflt; end
    if length(fontsize)<2, fontsize = fontsize([1 1]'); end
    
    % Create a time string ............
    time = clock;
    cstr = num2str(time(5));
    if length(cstr)==1, cstr = ['0' cstr]; end  % Add '0' for minutes
    d = date;
    if ishm, d = [d ', ' num2str(time(4)) ':' cstr]; end
    string = [name '  ' d];
    
    % Make an invisible axes ..........
    ah = axes('units','normal','pos',[0 0 1 1]);
    set(ah,'xlim',[0 1],'ylim',[0 1])
    set(ah,'xtick',[], 'ytick',[])
    
    th = text(pos(1,1),pos(1,2),string);  % The first text
    set(th,'fontsize',fontsize(1),'fontname',ftname,'color',color)
    drawnow
    ext = get(th,'extent');
    if size(pos,1)<2
        pos(2) = pos(2)-offset*ext(4);
    else
        pos = pos(2,:);
    end
    if ~isempty(logo)                           % If "logo" is added
        th(2) = text(pos(1),pos(2),logo);
        set(th(2),'fontsize',fontsize(2),'fontname',ftname,'color',color)
    end
end
    
    
