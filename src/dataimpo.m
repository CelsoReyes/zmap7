function dataimpo(in,in2)
    % read hypoellipse and other formated  data into a matrix a that can be used in zmap
    %
    % Stefan Wiemer; 6/95
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    myFigName='Data Import';
    
    
    report_this_filefun();
    % This is the info window text
    %
    
    setup_figure();
    
    % add a new label to the list
    function do_import(choice)
        switch choice
            % add a new option for your own data file format like that
            case "yours"
                da = 'eq';
                close;
                inda =1;
                yourload(da,inda);
                
            
            case "hypo35"
                da = 'eq';
                close;
                myload36();
                
            case "hypo88"
                da = 'eq';
                close;
                myload88();
                
            case "jma"
                in='initf';
                inda=1;
                mylojma(in,inda);
                
            case "hypo_str"
                in='initf';
                loadhypo('hypo_de');
                
            case "ascii"
                close;
                loadasci('earthquakes');
                
            otherwise
                warndlg("choose an import routine", "choose routine");
                return
            
        end
        
    end
    
    function setup_figure()
        % set up the figure
        
        titstr='The Data Input Window                        ';
        hlpStr= ...
            ['                                                '
            ' Allows you to Import data into zmap. At this   '
            ' You can either Import the data as ASCII colums '
            ' separated by blanks or as hypoellipse.         '
            ' To load an ASCII file seperated by blanks      '
            ' switch the popup Menu FORMAT to ASCII COLUMNS. '];
        
        
        importChoice = ["Choose a data format",...
            "Ascii columns",...
            "Read formatted (Hypo 88 char - NCEDC format)",...
            "Read formatted (Hypo 36 char - AEIC Format)", ...
            "Read formatted (your format)", " Hypoellipse (string conversion)",...
            "JMA Format"];
        
        shortChoice = ["choose","ascii","hypo88", "hypo35", "yours", "hypo_str","jma"];
        
        lohy=findobj('Type','Figure','-and','Name',myFigName);
        
        
        % Set up the window Enviroment
        %
        if isempty(lohy)
            lohy = figure(...
                'Units','centimeter','pos',[0 3 18 6],...
                'Name',myFigName,...
                'visible','on',...
                'NumberTitle','off',...
                'Menu','none',...
                'NextPlot','add');
            axis off
        else  % if figure exist
            
            figure(lohy)
            clf
        end
        
        uicontrol('BackGroundColor',[0.9 0.9 0.9],'Style','Frame',...
            'Units','centimeter',...
            'Position',[0.6 0.5   17  4.5]);
        
        uicontrol('Style','text',...
            'Units','centimeter','Position',[1 3.0   3  0.8],...
            'String','Format:');
        
        labelPos = [5 3.0 11 0.8];
        hImportChoice=uicontrol(...
            'Style','popup',...
            'Units','centimeter',...
            'Position',labelPos,...
            'String',importChoice,...
            'callback',@callbackfun_001);
        
        
        function callbackfun_001(mysrc,myevt)
            
            callback_tracker(mysrc,myevt,mfilename('fullpath'));
            in2 = shortChoice(hImportChoice.Value);
            do_import(in2);
        end
        
    end
end