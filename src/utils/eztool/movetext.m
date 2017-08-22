function movetext(command)
    % FUNCTION MOVETEXT(COMMAND)
    % This is a callback designed to be called by a
    % WindowButtonDown event.  COMMAND dictates the
    % function's behavior. Basically, the function
    % handles mouse-controlled movement and rotation
    % of text.
    %
    % Keith Rogers 11/30/93

    global  movetext_pos
    global oldtextobj;

    if(command < 3)	  % If we're setting up a buttondown funtion

        %%%%%%%%%%%%%%%%%%%%%%%
        % De-select old objects
        %%%%%%%%%%%%%%%%%%%%%%%

        if(oldtextobj ~= gco)
            if(isobj(oldtextobj))
                set(oldtextobj,'Selected','off');
            end
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Make sure we are dealing with a text object
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if(strcmp(get(gco,'Type'),'text'))
            set(gco,'Selected','on');
            oldtextobj = gco;
            set(gco,'Selected','on');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set up functions for a text move
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if(command == 1)
                set(gcf,'WindowButtonMotionFcn','movetext(7)');
                set(gcf,'WindowButtonUpFcn','movetext(6)');

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Set up functions for a text rotate
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            elseif(command == 2)

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Icky coordinate transforms
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%

                oldunits = get(gco,'Units');
                set(gco,'Units','normalized');
                axpos = get(gca,'position');
                txtpos = get(gco,'position');
                txtext = get(gco,'extent');
                set(gco,'Units',oldunits);
                movetext_pos(1) = axpos(1)+axpos(3)*txtpos(1);
                movetext_pos(2) = axpos(2)+axpos(4)*txtpos(2);
                ext(1) = axpos(1)+axpos(3)*txtext(1);
                ext(2) = axpos(2)+axpos(4)*txtext(2);
                ext(3) = axpos(3)*txtext(3);
                ext(4) = axpos(4)*txtext(4);
                set(gcf,'units','normalized');
                currpos = get(gcf,'currentpoint');

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Only activate if we're clicking inside
                % the bounds of the text's box.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if(currpos(1) > ext(1) & currpos(1) < ext(1)+ext(3)...
                        &  currpos(2) > ext(2) & currpos(2) < ext(2)+ext(4))
                    set(gcf,'WindowButtonMotionFcn','movetext(5)',...
                        'WindowButtonUpFcn','movetext(6)');
                    set(gco);
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Do the rotate (this is for WindowButtonMotionFcn)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif(command == 5)
        currpos = get(gcf,'currentpoint');
        theta=180/pi*atan2(currpos(2)-movetext_pos(2),currpos(1)-movetext_pos(1));
        set(gco,'rotation',theta);

        %%%%%%%%%%%%%%%%%%%%
        % WindowButtonUpFcn
        %%%%%%%%%%%%%%%%%%%%

    elseif(command == 6)
        set(gco);
        set(gcf,'WindowButtonMotionFcn','');
        set(gcf,'WindowButtonUpFcn','');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Do the Text Move (this is for WindowButtonMotionFcn)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif(command == 7)
        p = get(gca,'CurrentPoint');
        set(gco,'Position',[p(1,1) p(1,2) p(1,3)]);
    end
