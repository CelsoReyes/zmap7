
% attempt for hazard mapping ..
% hazard at one location due to all sources.
% Warning: Not tested much an probably wrong
%
% make the interface
%
if exist('dohaz') == 0 ; dohaz = 'in1' ;phazmap; end

m0=maepi(:,6);
pgalev = 0.1;
ranz1 = [];
ranz2 = [];
P = [];
abcp(:,7:8) = [0];
switch(dohaz)

    case 'in1'
        figure_w_normalized_uicontrolunits(...
            'Name','Hazard Input Parameter',...
            'NumberTitle','off', ...
            'MenuBar','none', ...
            'units','points',...
            'Visible','on', ...
            'Position',[ wex+200 wey-200 450 200]);
        axis off

        labelList2=['Generic California Model | Spatially Varying Model'];
        labelPos = [0.1 0.77  0.7  0.08];
        hndl2=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList2,...
            'Callback','inb2 =get(hndl2,''Value''); ');

        set(hndl2,'value',1);


        labelList2=['Attenuation Joyner and Boore (1997) | others  ...'];
        labelPos = [0.1 0.57  0.7  0.08];
        hndl3=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList2,...
            'Callback','inb2 =get(hndl3,''Value''); ');

        set(hndl3,'value',1);


        labelList3=['Compute X probability of exceeding in T   | Compute probability of exeeding Z PGA in T '];
        labelPos = [0.1 0.42  0.7  0.08];
        hndl4=uicontrol(...
            'Style','popup',...
            'Position',labelPos,...
            'Units','normalized',...
            'String',labelList3,...
            'Callback','inb3 =get(hndl4,''Value''); ');

        close_button=uicontrol('Style','Pushbutton',...
            'Position',[.50 .05 .15 .12 ],...
            'Units','normalized','Callback','close;done','String','Cancel');

        help_button=uicontrol('Style','Pushbutton',...
            'Position',[.70 .05 .15 .12 ],...
            'Units','normalized','Callback','close;done','String','Help');


        go_button1=uicontrol('Style','Pushbutton',...
            'Position',[.20 .05 .15 .12 ],...
            'Units','normalized',...
            'Callback','inb1 =get(hndl2,''Value'');inb2 =get(hndl3,''Value'');inb3 =get(hndl4,''Value'');close;drawnow;dohaz =''in2'', phazmap',...
            'String','Go');


    case 'in2'

        if inb1 == 1
            prompt   = {'Enter  minimum magnitude used:',...
                'Enter maximum magnitude used:',...
                'Enter probability level:',...
                'Enter forecast period'};
            %        'Enter assumed b-value'};

            title    = 'Hazard map input parameters - Generic California';
            lines = 1;
            def     = {'4.5','7.5','0.1','50'};
            answer   = inputdlg(prompt,title,lines,def);
            MMIN = str2double(answer{1,1});
            MMAX = str2double(answer{2,1});
            problev = str2double(answer{3,1});
            T = str2double(answer{4,1});
            %ass_b = str2double(answer{5,1});

            le = length(abcp);
            dm = 0.1;K = 0;
            le2 = le*length(MMIN:dm:MMAX);
            Y0 = zeros(le2,1);
            P = zeros(le2,1);
            ste = (1:le:le2+le);
            drawnow
            dohaz ='comp'; phazmap;

        elseif inb1 == 2

            prompt   = {'Enter  minimum magnitude used:',...
                'Enter maximum magnitude used:',...
                'Enter probability level:',...
                'Enter forecast period'};
            title    = 'Hazard map input parameters - Spatially Varying';
            lines = 1;
            def     = {'4.5','7.5','0.1','50'};
            answer   = inputdlg(prompt,title,lines,def);
            MMIN = str2double(answer{1,1});
            MMAX = str2double(answer{2,1});
            problev = str2double(answer{3,1});
            T = str2double(answer{4,1});

            le = length(abcp);
            dm = 0.1;K = 0;
            le2 = le*length(MMIN:dm:MMAX);
            Y0 = zeros(le2,1);
            P = zeros(le2,1);
            ste = (1:le:le2+le);
            drawnow;
            dohaz ='comp'; phazmap;
        end


    case 'comp'

        anan = isnan(abcp(:,4));

        for i = 1:length(abcp)

            x = abcp(i,5);
            y = abcp(i,6);
            di2 = deg2km((distance(abcp(:,6),abcp(:,5),repmat(y,le,1),repmat(x,le,1))));
            l = di2 < 1;
            di2(l) = di2(l)*+10;
            r = di2;
            dt = .1;
            t = 10:dt:11;
            T = t(length(t))-t(1);
            for m = MMIN:dm:MMAX;
                K = K+1;

                % Y is attenuation relationship & gives a ground acc for each node
                % ste contains a node for each grid node, for each m step
                % r (a vector) is the distance from the source zone to the site
                % af = ???? a, but how? bvg(:,5) =  radius of sample area for b calc

                Y = 0.53*(m-6) - 0.39*log(r.^2 + 31) + 0.25;
                Y = exp(Y);
                Y0(ste(K):ste(K+1)-1) = Y;

                %af = log10(bvg(:,5)) + ass_b*min(a(:,6));

                if inb1 == 1
                    % generic california model
                    for ir = 1:length(t)
                        %                     ranz1(1:length(abcp),ir) = 10.^(-1.67+.91*(m0-m)).*(t(ir)+.05).^(-1.08)*dt;
                        %                     ranz2(1:length(abcp),ir) = 10.^(-1.67+.91*(m0-(m+0.1))).*(t(ir)+.05).^(-1.08)*dt;
                        ranz1(1:length(abcp),ir) = 10.^(-1.34+.78*(m0-m)).*(t(ir)+.05).^(-.84)*dt;
                        ranz2(1:length(abcp),ir) = 10.^(-1.34+.78*(m0-(m+0.1))).*(t(ir)+.05).^(-.84)*dt;
                    end
                    %anz1 = 10.^(af-ass_b*m);
                    %anz2 = 10.^(af-ass_b*(m+0.1));
                    ian = isnan(abcp(:,4));
                    anz1 = sum(ranz1,2);
                    anz2 = sum(ranz2,2);
                    anz1(ian) = 0;
                    anz2(ian) = 0;
                elseif inb1 == 2
                    % spatial model
                    for ir = 1:length(t)
                        ranz1(:,ir) = 10.^(abcp(:,1)+abcp(:,2)*(m0-m)).*(t(ir)+abcp(:,3)).^-abcp(:,4)*dt;
                        ranz2(:,ir) = 10.^(abcp(:,1)+abcp(:,2)*(m0-(m+.01))).*(t(ir)+abcp(:,3)).^-abcp(:,4)*dt;
                        %                     ranz1(anan,ir) = 0;
                        %                     ranz2(anan,ir) = 0;
                    end
                    anz1 = sum(ranz1,2);
                    anz2 = sum(ranz2,2);
                    %anz1 = 10.^(bvg(:,8)-bvg(:,1)*m);
                    %anz2 = 10.^(bvg(:,8)-bvg(:,1)*(m+0.1));
                end


                anz = anz1 - anz2;
                % normalize for the area
                % anz is a vector -- different values for each node!!!
                % t0b and teb come from bvalgrid and are for all of a
                anz = anz*dx*dy*111*111./(pi*ra.^2);
                % Ptr is the rate for the given time period (an actual rate)
                Ptr = anz./(t(length(t))-t(1));
                % P sets the rate (events/time) for every node for the given mag bin
                P(ste(K):ste(K+1)-1)  = Ptr;
            end % for m

            K=0;  % Reset counter
            PG = zeros(0:0.02:0.8,2);
            I = 0;
            % Sum up all obs groud motions
            l = isnan(P);
            P(l) = [];
            Y0(l) = [];

            for k = 0:0.02:1.0
                I = I+1;
                % Y0 is the obs ga
                l = Y0 > k;
                pg = sum(P(l));
                if pg == 1.0
                    pg = nan;
                end
                PG(I,:) = [pg k ];
            end

            % Compute hazard
            P2 = 1-exp(-PG(:,1)*T);

            if inb3 == 1
                % PGA map
                fi = max(find(abs(P2-problev) == min(abs(P2-problev))));
                P10 = PG(fi,2)
                abcp(i,7) = P10;
            elseif inb3 == 2
                % probablity map
                P2 = 1-exp(-PG(:,1)*T);
                P10 = interp1(PG(:,2),P2,pgalev);
                disp([num2str(P10),' ',num2str(i)]);

            end

            abcp(i,8) = P10;
            waitbar(i/length(abcp));
        end  % for i



        %     for ii = 1:length(abcp)
        %         if abcp(ii,5) < abcp(ii+1,5)
        %             lyvect = ii;
        %             lxvect = length(abcp)/lyvect;
        %             break
        %         end
        %     end
        ll = gll;
        normlap2=zeros(size(gll));
        normlap2(ll)= abcp(:,8);
        Pmap=reshape(normlap2,length(yvect),length(xvect));

        normlap2(ll)= abcp(:,8);
        re3=reshape(normlap2,length(yvect),length(xvect));

        lab1 = 'HPGA [g]'
        view_hpga


end

