classdef plotmymap < ZmapFunction
    % plotmymap Plots a map using m_map
    properties
        OperatingCatalog={'primeCatalog'}; % catalog(s) containing raw data.
        ModifiedCatalog=''; % catalog to be modified after all calculations are done
        Projections={'Lambert Projection','Miller Projection','Mollweide Projection','Oblique Mercator'};
        Resolutions={' Crude resolution','Low Resolution','Intermediate Resolution (slow)','High Resolution (slower)'};
        OceanColors={'Ocean White','Ocean light blue',''};
        Details={'Land patched','coastlines only'};
        proj=1;
        resolutin=1
        ocean_color=1;
        details=1;
    end
    
    properties(Constant)
        PlotTag='myplot';
    end
    
    properties
        % declare all the variables that need to be shared in this program/function, but that the end user
        % won't care about.
    end
    
    methods
        function obj=plotmymap(varargin) %CONSTRUCTOR
            % create a [...]
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            error('the functionality in this has been replaced by get_basemap_parts');
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
            zdlg.addBasicPopup('proj','Projection',obj.Projections,obj.proj); %hndl2
            zdlg.addBasicPopup('resolution','Resolution',obj.Resolutions,obj.resolution); %hndl3
            zdlg.addBasicPopup('ocean_color','Ocean Color',obj.OceanColors,obj.ocean_color); %hndl4
            zdlg.addBasicPopup('detail','What to plot',obj.OceanColors,obj.detail); %hndl5
            % for some reason, every callback used to set "inb2"
            
            uicontrol('Style','Pushbutton',...
                'Position',[.70 .05 .25 .12 ],...
                'Units','normalized',...
                'Callback','web https://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/',...
                'String','Get GSHHS data');
            
            zdlg.Create('GSHHS Parameters')
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
            
            % check for data existence
            FILNAME=obj.getfilename();
            
            if ~exist(FILNAME,'file')
                st1 = [' The GSHHS data-base you requested was not found in m_map/private'...
                    'Please check the path of the data or download/uncompress the GSHHS files from to ftp://ftp.ngdc.noaa.gov/MGG/shorelines/ ' ];
                
                errordlg(st1,'Error: File not found ');
                
                return
            end
            
            
            h1=findobj('Name','Lambert Map','-and','Type','Figure');
            if isempty(h1)
                ac3 = 'new';
                overmap();
            end
            h1=findobj('Name','Lambert Map','-and','Type','Figure');
            if ~isempty(h1)
                h1 = figure(to1);
                delete(findobj(h1,'Type','axes'));
            end
            
            watchon
            drawnow
            l  = get(h1,'XLim');
            s1 = l(2); s2 = l(1);
            l  = get(h1,'YLim');
            s3 = l(2); s4 = l(1);
            
            projs={'lambert','miller','mollweide','Oblique Mercator'};
            mproj(projs{obj.proj},'long',[s2 s1],'lat',[s4 s3]);
            resOrder='clih';
            indicator=resOrder(obj.resolution);
            myfn=str2func(['m_gshhs_' indicator]);
            
            if obj.detail == 1
                myfn('patch',[.8 .8 .8]);
                FILNAME=obj.getfilename();
            elseif obj.detail == 2
                myfn('line');
            end
            
            
            if ~isempty(faults)
                lifa = m_line(faults(:,1),faults(:,2),'color','r'); 
            end
            
            hold on
            
            if co == 'w'
                co = 'k'; 
            end
            li = m_plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude);
            set(li,'Linestyle','none','Marker',ty1,'MarkerSize',ZG.ms6,'color',co)
            
            if exist('vo', 'var')
                if ~isempty(vo)
                    li = m_plot(vo.Longitude,vo.Latitude);
                    set(li,'Linestyle','none','Marker','^','MarkerSize',6,'markeredgecolor','r','markerfacecolor','w')
                end
            end
            
            
            m_grid('box','on','tickdir','out','linestyle','none','color','k');
            set(gcf,'Color','w')
            oco =  findobj('tag','m_grid_color');
            
            if obj.ocean_color == 2
                set(oco,'FaceColor',[0.85 0.85 1 ]);
            end
            mapax = gca;
            
            uicontrol('Style','Pushbutton',...
                'Position',[.002 .002 .45 .05 ],...
                'Units','normalized',...
                'Callback','selt = ''sa''; savecoast2',...
                'String','Import coastline to map window');
            % results of the calculation should be stored in fields belonging to obj.Result
            
            obj.Result.Data=[];
            
        end
        
        function plot(obj,varargin)
            % plots the results somewhere
            f=obj.Figure('deleteaxes'); % nothing or 'deleteaxes'
            
            obj.ax=axes(f);
            
            % do the plotting
            % obj.hPlot=plot(obj.ax, obj.Result.x,obj.Result.y, obj.lstyle, varargin{:});
            
            % do the labeling
            % xlabel(obj.ax,['zmapFunction plot: ', obj.plotlabel]);
        end
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
            % obj.ZG.SOMETHING = obj.Results.SOMETHING
            
            FILNAME
        end
        
        function save(obj)
            axes(mapax);
            FILNAME=obj.getfilename();
            mapfun=obj.getmapsfunction();
            mapfun('save','coastl.mat');
            load coastl.mat
            
            coastline = ncst;
            update(mainmap())
            clear  ncst coastl
            
        end
        
        function fn = getfilename(obj)
            resOrder='clih';
            indicator=resOrder(obj.resolution);
             fn=fullfile('private',['gshhs_', indicator, '.b']);
        end
        
        function myfn = getmapsfunction(obj)
            resOrder='clih';
            indicator=resOrder(obj.resolution);
            myfn=str2func(['m_gshhs_' indicator]);
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','testmenuitem',...    CHANGE THIS TO YOUR MENUNAME
                'Callback', @(~,~)plotmymap()... CHANGE THIS TO YOUR CALLBACK
                );
        end
        
    end % static methods
    
end %classdef


