classdef findquar < ZmapFunction
    % description of this function
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items... 
    %     h=sample_ZmapFunction.AddMenuItem(hMenu) %create subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then sample_ZmapFunction.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    
    properties
        OperatingCatalog={'a'}; % catalog(s) containing raw data.
        ModifiedCatalog=''; % catalog to be modified after all calculations are done
        
        EvtSel
        Grid
    end
    
    properties(Constant)
        PlotTag='myplot';
    end
    
    properties
        % declare all the variables that need to be shared in this program/function, but that the end user
        % won't care about.
    end
    
    methods
        function obj=blank_ZmapFunction(varargin) %CONSTRUCTOR
            % create a [...]
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            if nargin==0
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                %run this function without human interaction
                
                % set values for properties
                
                ...
                
                % run the rest of the program
                obj.doIt();
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            % ask for 
            
            zdlg=ZmapFunctionDlg(...
                obj,...  pass it a handle that it can change when the OK button is pressed.
                @obj.doIt...  if OK is pressed, then this function will be executed.
                );
            
            %----------------------------
            % The dialog box is a vertically oriented series of controls
            % that allow you to choose parameters
            %
            %  every procedure takes a tag parameter. This is the name of the class variable
            %  where results will be stored for that field.  Results will be of the same type
            %  as the provided values.  That is, if I initialize a field with a datetime, then
            %  the result will be converted back to a datetime. etc.
            %
            % add items ex.  :
            %  zdlg.AddBasicHeader  : add line of bold text to separate areas
            %  zdlg.AddBasicPopup   : add popup that returns the # of chosen line
            %  zdlg.AddGridParameters : add section that returns grid defining params
            %  zdlg.AddBasicCheckbox : add checkbox that returns state, 
            %                          and may affect other control's enable states
            %  zdlg.AddBasicEdit : add basic edit field & edit field label combo
            %  zdlg.AddEventSelectionParameters : add section that returns how grid points
            %                                     may be evaluated
           
            zdlg.AddGridParameters('Grid',1.0,'deg',1.0,'deg',[],[]);
            zdlg.AddEventSelectionParameters('EvtSel',100,[]);
              % get the grid parameter
        % initial values
        %
        dx = 1.00; % found in obj.Grid.dx
        dy = 1.00 ; % found in obj.Grid.dy
        ni = 100; % found in obj.evtsel.numNearbyEvent
    
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'callback',@cb_gethrs,...
            'String','Go');

            
            zdlg.Create('my dialog title')
            % The dialog runs. if:
            %  OK is pressed -> assigns 
        end
        
        function CheckPreconditions(obj)
            % check to make sure any inportant conditions are met. 
            % for example, 
            % - catalogs have what are expected.
            % - required variables exist or have valid values
            assert(true==true,'laws of logic are broken.');
        end
        
        function Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            
            % create the function call that someone could use to recreate this calculation.
            %
            % for example, if one would call this function with:
            %      myfun('bob',23,false);
            % with values that get assigned the variables:
            %     obj.name, obj.age, obj.runreport
            % then the next line should be:
            %      obj.FunctionCall={'name','age','runreport'};
            
            obj.FunctionCall={};
            
        D = [];
        for i = 1:24
            j = findobj('tag',num2str(i));
            k = get(j,'value');
            if k == 1; D = [D i]; end
        end
        D = D-1;
        
        close(findobj('Tag','fifhr'));
        
        
        selgp
        itotal = length(newgri(:,1));
        %  make grid, calculate start- endtime etc.  ...
        %
        t0b = min(ZG.a.Date)  ;
        n = ZG.a.Count;
        teb = max(ZG.a.Date) ;
        tdiff = round((teb-t0b)/ZG.bin_dur);
        loc = zeros(3, length(gx)*length(gy));
        
        % loop over  all points
        %
        i2 = 0.;
        i1 = 0.;
        bvg = [];
        allcount = 0.;
        wai = waitbar(0,' Please Wait ...  ');
        set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
        drawnow
        %
        ld = length(D);
        ln = 24 - ld;
        
        
        % loop over all points
        for i= 1:length(newgri(:,1))
            x = newgri(i,1);y = newgri(i,2);
            allcount = allcount + 1.;
            i2 = i2+1;
            
            % calculate distance from center point and sort wrt distance
            l=ZG.a.epicentralDistanceTo(x,y);
            [s,is] = sort(l);
            b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
            
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            
            % call the b-value function
            
            
            l2 = sort(l);
            l = ismember(b(:,8),D);
            %l = b(:,8) >=7 & b(:,8) <=18;
            day = b(l,:);
            nig = b;
            nig(l,:) = [];
            rat = length(day(:,1))/length(nig(:,1)) * ln/ld;
            
            bvg = [bvg; rat  x y l2(ni) ];
            waitbar(allcount/itotal)
        end  % for newgr
        
        close(wai)
        watchoff
        
        % plot the results
        % old and valueMap (initially ) is the b-value matrix
        %
        normlap2=nan(length(tmpgri(:,1)),1)
        normlap2(ll)= bvg(:,1);
        valueMap=reshape(normlap2,length(yvect),length(xvect));
        
        normlap2(ll)= bvg(:,4);
        r=reshape(normlap2,length(yvect),length(xvect));
        
        old = valueMap;
        
        % View the b-value map
        view_qva
            % results of the calculation should be stored in fields belonging to obj.Result
            
            obj.Result.Data=[];
            
        end
        
        function plot(obj,varargin)
            % plots the results somewhere
            f=obj.Figure('deleteaxes'); % nothing or 'deleteaxes'
            
            obj.ax=axes(f);
            
        
        fifhr=figure_w_normalized_uicontrolunits(...
            'Name','Daytime (explosion) hours',...
            'NumberTitle','off', ...
            'NextPlot','new', ...
            'units','points',...
            'Visible','on', ...
            'Tag','fifhr',...
            'Position',[ 100 200 400 450]);
        axis off
        text(...
            'Position',[0. 0.90 0 ],...
            'FontSize',ZmapGlobal.Data.fontsz.m ,...
            'FontWeight','bold',...
            'String',' Select the daytime hours and then ''GO''  ');
        
        hold on
        axes('pos',[0.1 0.2 0.6 0.6]);
        histogram(ZG.a.Date.Hour,-0.5:1:24.5);
        [X,N] = hist(ZG.a.Date.Hour,-0.5:1:24.5);
        
        xlabel('Hr of the day')
        ylabel('Number of events per hour')
        
        
        for i = 1:24
            hourly(i)=uicontrol('Style','checkbox',...
                'string',[num2str(i-1) ' - ' num2str(i) ],...
                'Position',[.80 1-i/28-0.03 .17 1/26],'tag',num2str(i),...
                'Units','normalized');
        end
        
        % turn on checkboxes according to their percentile score
        idx = X > prctile2(X,60);
        for i = 1:length(idx)
            hourly(i).Value=idx(i);
        end
        
        %{
        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.0 .05 .1 .1 ],...
            'Units','normalized',...
            'callback',@callbackfun_006,...
            'String','Go');
        %}
        if isempty(findobj(gcf,'Tag','quarryinfo'))
            add_menu_divider();
            uimenu('Label','Info','callback',@cb_info,'tag','quarryinfo');
            uimenu('Label','Go','callback',@cb_calculate);
        end
        
            % do the plotting
            % obj.hPlot=plot(obj.ax, obj.Result.x,obj.Result.y, obj.lstyle, varargin{:});
 
            % do the labeling
            % xlabel(obj.ax,['zmapFunction plot: ', obj.plotlabel]);
        end
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
           % obj.ZG.SOMETHING = obj.Results.SOMETHING
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','testmenuitem',...    CHANGE THIS TO YOUR MENUNAME
                'Callback', @(~,~)blank_ZmapFunction()... CHANGE THIS TO YOUR CALLBACK
                );
        end
        
    end % static methods
    
end %classdef

%% Callbacks

% All callbacks should set values within the same field. Leave
% the gathering of values to the SetValuesFromDialog button.


    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        ni=str2double(freq_field.String);
        freq_field.String=num2str(ni);
    end
    
    function callbackfun_002(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dx=str2double(freq_field2.String);
        freq_field2.String=num2str(dx);
    end
    
    function callbackfun_003(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        dy=str2double(freq_field3.String);
        freq_field3.String=num2str(dy);
    end
    
    function cb_cancel(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        done;
    end
    
    function cb_gethrs(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        close;
        sel ='hr';
        findquar('hr');
    end
    
    function cb_calculate(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        sel ='ca';
        findquar('ca');
    end
    
    function cb_info(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        web(['file:' ZG.hodi '/help/quarry.htm']) ;
    end
    
