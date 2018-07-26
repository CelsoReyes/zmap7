classdef stressgrid < ZmapHGridFunction
    properties
        
    end
    
    properties(Constant)
        PlotTag         = 'stressgrid';
        ReturnDetails   = { ... VariableNames, VariableDescriptions, VariableUnits
            ...
            'S1Trend',  'S1Trend','';...
            'S1Plunge', 'S1Plunge','';...
            'S2Trend',  'S2Trend','';...
            'S2Plunge', 'S2Plunge','';...
            'S3Trend',  'S3Trend','';...
            'S3Plunge', 'S3Plunge','';...
            'Variance', 'Variance',''...
            }
        
        CalcFields = {...
            'S1Trend',  'S1Plunge',...
            'S2Trend',  'S2Plunge',...
            'S3Trend',  'S3Plunge',...
            'Variance'};
        
        ExtDir = fullfile(ZmapGlobal.Data.hodi, 'external');
        ParameterableProperties = [];
    end
    methods
        function obj = stressgrid(zap, varargin)
            % STRESSGRID calculate stress tensor using Michaels  code
            
            % NotImplemented: or Gephards code
            
            obj@ZmapHGridFunction(zap, 'S1Trend');
            report_this_filefun();
            
            obj.parseParameters(varargin);
            obj.StartProcess();
            
        end
        
        function InteractiveSetup(obj)
            %{
                dx = 0.1;
                dy = 0.1 ;
                ni = 50;
                ra = ZG.ra;
                Nmin = 0;
            %}
            
            zdlg = ZmapDialog();
            zdlg.AddBasicPopup('calcmethod','Calc Method',{'Michaels Method'},1,...
                'Choose the only method that is available. (sorry, no other options)');
            
            zdlg.AddEventSelectionParameters('evsel', obj.EventSelector)
            [res, okpressed]=zdlg.Create('Stress grid options');
            if ~okpressed
                return
            end
            obj.EventSelector=res.evsel;
            % Set Values From Dialog
            
            obj.doIt()
        end
        
        function results = Calculate(obj)
            % get the grid-size interactively and
            % calculate the b-value in the grid by sorting
            % the seismicity and selectiong the ni neighbors
            % to each grid point
            
            % get new grid if needed
            d = pwd;
            
            switch computer
                case 'GLNX86'
                    postfix = '_linux';
                case 'MAC'
                    postfix = '_macppc';
                case 'MACI'
                    postfix = '_maci';
                case 'MACI64'
                    postfix = '_maci64';
                otherwise
                    postfix = '.exe';
            end
            
            slick_cmd = sprintf('".%cslick%s" ',filesep, postfix); % eg.   >> "./slick.exe" data2
            slfast_cmd = sprintf('"%s%cslfast%s" ', obj.ExtDir,filesep, postfix);
            
            try
                cd(obj.ExtDir);
                itter=1;
                % calculate at all points
                obj.gridCalculations(@calculation_function);
                
                cd(d);
                
            catch ME
                
                cd(d);
                rethrow(ME)
                
            end
            
            if nargout
                results=obj.Result.values;
            end
            f=gcf;
            try
            obj.view_stressmap()
            catch ME
                warning(ME.message)
            end
            figure(f);
            
            function bvg = calculation_function(b)
                % returns: S1Trend S1Plunge S2Trend S2Plunge S3Trend S3Plunge Variance Radius b-value
                
                %estimate the completeness and b-value
                % Take the focal mechanism from actual catalog
                % tmpi-input: [dip direction (East of North), dip , rake (Kanamori)]
                %{
                tic
                itter=itter+1;
                inputFile = "dataz"+itter;
                outputFile = inputFile + ".oput";
                outputFileBoot = inputFile + ".slboot";
                
                
                % disp('writing raw inversion data to : ' + inputFile);
                % Create file for inversion
                fid = fopen(inputFile,'w');
                fprintf(fid,'%s \n', 'Inversion data');
                for i=1:b.Count
                    fprintf(fid,'%7.3f  %7.3f  %7.3f\n', b.DipDirection(i), b.Dip(i), b.Rake(i));
                end
                fclose(fid);
                
                % slick calculates the best solution for the stress tensor according to
                % Michael(1987): creates data2.oput
                % disp('slick')
                [mystatus, myresult] = system(slick_cmd + inputFile);
                
                % Get data from data2.oput
                
                [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(outputFile);
                % Stress tensor inversion
                [mystatus, myresult] = system(slfast_cmd + inputFile); % --> writes to outputFileBoot
                
                sGetFile = fullfile(obj.ExtDir, outputFileBoot); %'data2.slboot'
                
                % Description of data2
                % Line 1: Variance S11 S12 S13 S22 S23 S33 => Variance and components of stress tensor (S = sigma)
                % Line 2: Phi S1t S1p S2t S2p S3t S3p   => Phi is relative size S3/S1, t=trend, p=plunge (other description)
                
                                % Result matrix
                % S1Trend, S1Plunge, S2Trend, S2Plunge, S3Trend, S3Plunge, Variance // ignored: Radius, bvalue

                d0=load(sGetFile, inputFile);
                bvg_old = [d0(2,2:7) d0(1,1)];
                
                if isfile(inputFile)
                    delete(inputFile);
                end
                if isfile(outputFile)
                    delete(outputFile);
                end
                if isfile(outputFileBoot)
                    delete(outputFileBoot);
                end
                
                
                toc
                disp('^-old   new-v');
                %}
                tic
                
                %[fBeta2, fStdBeta2, fTauFit2, fAvgTau2, fStdTau2]=slick([b.DipDirection b.Dip b.Rake]);
                [bvg(7), ~, ~, bvg(1), bvg(2), bvg(3), bvg(4), bvg(5), bvg(6)]=slick([b.DipDirection b.Dip b.Rake]);
                toc

            end
        end
        
        function view_stressmap(obj) % autogenerated function wrapper
            % view_stressmap
            % pulled into function due to its tight bonding from an m file
            % Author: S. Wiemer
            % updated: 19.05.2005, j.woessner@sed.ethz.ch
            % turned into function by Celso G Reyes 2017
            %FIXME this has never been updated
            
            values = obj.Result.values;
            
            ZG=ZmapGlobal.Data;
            SA = 1;
            SA2 = 3;
            
            % Matrix bvg contains:
            % bvg : [S1Trend S1Plunge S2Trend S2Plunge S3Trend S3Plunge Variance Radius b-value]
            % ste : [S1Plunge S1Trend+180 S2Plunge S2Trend+180 S3Plunge S3Trend+180 Variance];
            %ste = [bvg(:,2) bvg(:,1)+180  bvg(:,4) bvg(:,3)+180 bvg(:,6) bvg(:,5)+180 bvg(:,7) ];
            ste = [values.S1Plunge values.S1Trend+180  values.S2Plunge values.S2Trend+180 values.S3Plunge values.S3Trend+180 values.Variance ];
            sor = ste;
            % sor : [S1Plunge S1Trend+270 S2Plunge S2Trend+180 S3Plunge S3Trend+180 Variance];
            sor(:,SA*2) = sor(:,SA*2)+90;
            
            % Create matrices
            normlap2=NaN(height(values),1);
            
            valueMap=normlap2;%reshape(normlap2,length(yvect),length(xvect));
            %s11 = valueMap;
            
            % Create figure
            % fig=figure('visible','off');
            l_normal =  ste(:,1) > 52 &   ste(:,5) < 35 ;
            l_notnormal = l_normal < 1;
            ax=axes(figure);
            plq = quiver(ax,values.x(l_notnormal),values.y(l_notnormal),-cos(sor(l_notnormal,SA*2)*pi/180),sin(sor(l_notnormal,SA*2)*pi/180),0.6,'.');
            set(plq,'LineWidth',0.5,'Color','k')
            px = get(plq,'Xdata');
            py = get(plq,'Ydata');
            
            
            
            % fig=figure('visible','off')
            ax=axes(figure);
            plq_n = quiver(ax,values.x(l_normal),values.y(l_normal),-cos(sor(l_normal,SA2*2)*pi/180),sin(sor(l_normal,SA2*2)*pi/180),0.6,'.');
            set(plq_n,'LineWidth',0.5,'Color','r')
            
            drawnow
            px_n = get(plq_n,'Xdata');
            py_n = get(plq_n,'Ydata');
            %close
            
            fig=figure('Name','Faulting style map','pos',[100 100 860 600]);
            watchon;
            %whitebg(gcf);
            set(fig,'color','w');
            ax=axes('pos',[0.12 0.12 0.8 0.8]);
            set(ax,'NextPlot','add')
            n = 0;
            l0 = []; l1 = []; l2 = []; l3 = []; l4 = []; l5 = [];
            
            ste = sor(l_notnormal,:);
            for i = 1:3:length(px)-1
                n = n+1;
                j = jet;
                col = floor(ste(n,SA*2-1)/60*62)+1;
                if col > 64 
                    col = 64; 
                end
                pl = line(ax,px(i:i+1),py(i:i+1),'Linewidth',1,'Markersize',1);
                ax.NextPLot = 'add';
                
                dx = px(i)-px(i+1);
                dy = py(i) - py(i+1);
                pl2 = line(ax, px(i),py(i),'Marker','o','Markersize',0.1,'Linewidth',0.5);
                l0 = pl2;
                pl3 = line(ax,[px(i) px(i)+dx],[py(i) py(i)+dy],'Linewidth',1);
                
                % Select faulting style according to Zoback(1992)
                thecolor = [0 0 0];
                if ste(n,1) < 40  && ste(n,3) > 45  && ste(n,5) < 20 
                    thecolor = [0.2 0.8 0.2];
                    l3 = pl; 
                end
                if ste(n,1) < 20  && ste(n,3) > 45  && ste(n,5) < 40
                    thecolor =[0.2 0.8 0.2]; 
                    l3 = pl; 
                end
                if ste(n,1) > 40  &&                 ste(n,1) < 52  && ste(n,5) < 20 
                    thecolor = [1 0 1];
                    l2 = pl; 
                end
                if ste(n,1) < 20  &&                 ste(n,5) > 40  &&  ste(n,5) <  52
                    thecolor = [0 1 1];
                    l4 = pl; 
                end
                if ste(n,1) < 37  && ste(n,5) > 47
                    thecolor = [0 0 1];
                    l5 = pl;  
                end
                set([pl pl2 pl3], 'color', thecolor);
                
            end
            %drawnow
            ste = sor(l_normal,:);
            n = 0;
            
            for i = 1:3:length(px_n)-1
                n = n+1;j = jet;
                col = floor(ste(n,SA*2-1)/60*62)+1;
                if col > 64 ; col = 64; end
                dx_n = px_n(i)-px_n(i+1);
                dy_n= py_n(i) - py_n(i+1);
                pl_n = plot(ax, px_n(i:i+1),py_n(i:i+1),'k','Linewidth',1,'Markersize',1,'color',[ 0 0 0  ] );
                set(ax,'NextPlot','add')
                dx = px_n(i)- px_n(i+1);
                dy = py_n(i) - py_n(i+1);
                pl2_n = plot(ax, px_n(i),py_n(i),'ko','Markersize',0.1,'Linewidth',0.5,'color',[0 0 0] );
                l0 = pl2;
                pl3_n = plot(ax, [px_n(i) px_n(i)+dx_n],[py_n(i) py_n(i)+dy_n],'k','Linewidth',1,'color',[0 0 0] );
                
                if ste(n,1) > 52  &&                 ste(n,5) < 35 ;                 set([pl_n pl3_n],'color','r'); set(pl2_n,'color','r'); l1 = pl_n;
                end
            end
            
            if isempty(l1); pl2 = plot(px,py,'kx','Linewidth',1,'color','r'); l1 = pl2; %set(l1,'visible','off'); 
            end
            if isempty(l2); pl2 = plot(px,py,'kx','Linewidth',1,'color','m'); l2 = pl2; %set(l2,'visible','off');
            end
            if isempty(l3); pl2 = plot(px,py,'kx','Linewidth',1,'color',[0.2 0.8 0.2] ); l3 = pl2; %set(l3,'visible','off'); 
            end
            if isempty(l4); pl2 = plot(px,py,'kx','Linewidth',1,'color','c' ); l4 = pl2;% set(l4,'visible','off');
            end
            if isempty(l5); pl2 = plot(px,py,'kx','Linewidth',1,'color','b' ); l5 = pl2; %set(l5,'visible','off');
            end
            if isempty(l0); l0 = plot(px,py,'kx','Linewidth',1,'color',[0 0 0 ] );  % set(l0,'visible','off'); 
            end
            
            try
                legend([l1 l2 l3 l4 l5 l0],'NF','NS','SS','TS','TF','U');
            catch
                disp('Legend could not be drawn')
            end
            
            % Figure settings
            set(ax,'NextPlot','add')
            axis(ax, 'equal')
            % zmap_update_displays();
            set(ax,'PlotBoxAspectRatio',[0.827 1 1])
            %axis(ax,[ s2 s1 s4 s3])
            title(ax,sprintf('%s;  %g to %g', name, t0b, teb),'FontSize',ZmapGlobal.Data.fontsz.s,...
                'Color','k','FontWeight','normal');
            xlabel(ax,'Longitude ','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
            ylabel(ax,'Latitude ','FontWeight','normal','FontSize',ZmapGlobal.Data.fontsz.s)
            set(ax,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','normal',...
                'FontWeight','normal','LineWidth',1,...
                'Box','on','TickDir','out','Ticklength',[0.01 0.01])
            
            watchoff;
            
            % View the variance map
            valueMap = r;
            ZG.shading_style = 'interp';
            %view_varmap([],valueMap);
            set(ax,'NextPlot','add')
            
            obj.add_grid_centers();
            
            for n=1:numel(obj.features)
                ft=obj.ZG.features(obj.features{n});
                copyobj(ft,ax);
            end
            
        end
    end
    methods(Static)
       
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='Map Stress Tensor';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)stressgrid(zapFcn()));
        end
    end % static methods
end
%{
function bvg = stressgrid % autogenerated function wrapper
    % stressgrid create a grid (interactively), calculate stress tensor using Michaels or Gephards code
    %
    % Incoming data:
    % requires catalog contains
    %   * DipDirection (East of North)
    %   * Dip,
    %   * Rake (Kanamori Convention)
    %
    % original: Stefan Wiemer 1/95
    %
    % updated by: J. Woessner
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    fs=filesep;
    
    % get the grid parameter
    % initial values
    %
   
    
    dx = 0.1;
    dy = 0.1 ;
    ni = 50;
    ra = ZG.ra;
    Nmin = 0;
    
    zdlg = ZmapDialog();
    zdlg.AddBasicPopup('calcmethod','Calc Method',{'Michaels Method'},1,...
        'Choose the only method that is available. (sorry, no other options)');
    
    zdlg.AddEventSelectionParameters('EventSelector', ni, ra, Nmin)
    [res, okpressed]=zdlg.Create('Stress grid');
    if ~okpressed
        return
    end
    disp(res)
    Grid=ZG.gridopt;
    EventSelector=res.EventSelector;
    ZG.inb1=res.calcmethod;
    
    
    origdir=pwd;
    try
    my_calculate();
    catch ME
        cd(origdir)
        rethrow ME
    end

    
   
end
%}
