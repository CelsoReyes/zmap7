classdef sample_ZmapFunction < ZmapFunction
    % description of this function
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items...
    %     h=sample_ZmapFunction.AddMenuItem(hMenu) %c reate subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then sample_ZmapFunction.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    
    properties
        OperatingCatalog={'a','maepi'}; % catalog(s) containing raw data.
        ModifiedCatalog='newt2'; % catalog to be modified after all calculations are done
    end
    
    properties(Constant)
        PlotTag='myplot'
    end
    
    properties
        % declare all the variables that need to be shared in this program/function, but that the end user
        % won't care about.
        allEqCat;
        mainShock;
        radius=1;
        noiselevel=0.2;
        plotlabel='Drink';
        lstyle='-'
        lifechoice=2;
        choices={'Eat','Drink','Be Merry'};
        grid=[]
        usenoise=false
        cleverness=false
        evsel=[];
        
    end
    
    methods
        function obj=sample_ZmapFunction(radius, noiselevel,beclever)
            % create a sample_ZmapFunction
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            disp('sample.constructor');
            if nargin==0
                % create dialog box, then exit.
                obj.InteractiveSetup();
                
            else
                % run this function without human interaction
                
                % set my variables from the argument list
                obj.radius=radius;
                obj.usenoise=noiselevel ~= 0;
                obj.noiselevel = noiselevel;
                obj.cleverness = beclever;
                
                obj.doIt();
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation

            disp('sample.InteractiveSetup')
            
            zdlg=ZmapFunctionDlg(obj, @obj.doIt);
            
            %%%%%%%%%%%%%%%
            % add items ex.  :
            %  zdlg.AddBasicHeader  : add line of bold text to separate areas
            %  zdlg.AddBasicPopup   : add popup that returns the # of chosen line
            %  zdlg.AddGridParameters : add section that returns grid defining params
            %  zdlg.AddBasicCheckbox : add checkbox that returns state, 
            %                          and may affect other control's enable states
            %  zdlg.AddBasicEdit : add basic edit field & edit field label combo
            %  zdlg.AddEventSelectionParameters : add section that returns how grid points
            %                                     may be evaluated
            %%%%%%%%%%%%%%%
            zdlg.AddBasicHeader('Say something for each thing');
            zdlg.AddBasicPopup('lifechoice','life choice',obj.choices,2,'youer choice. your life.');
            zdlg.AddGridParameters('grid',0,'deg',3,'deg',5,'km');
            zdlg.AddBasicCheckbox('usenoise','use noise level', false,{'noiselevel','noiselevel_label'},'use noise levels?');
            zdlg.AddBasicEdit('noiselevel','Noise level', obj.noiselevel,'noise levels');
            zdlg.AddEventSelectionParameters('evsel',obj.ZG.ni, obj.ZG.ra);
            zdlg.AddBasicCheckbox('cleverness','be clever', false,[],'never be clever');
            
            zdlg.Create('my dialog title')
            
            % dialog runs.  if OK is pressed, then the function defined in
            % obj.doIt is run
        end
      
        function CheckPreconditions(obj)
            % check to make sure input catalogs meet this function's criteria
            disp('sample.CheckCatalogPreconditions')
            obj.allEqCat=obj.getCat(1);
            obj.mainShock=obj.getCat(2);
            
            assert(true==true, 'the laws of logic no longer apply.');
            % some random requirement examples.
            % assert(obj.mainShock.Count == 1,'mainshock catalog can have only one event');
            % assert(any(obj.allEqCat.Date > obj.mainShock.Date),'at least one event must exist after mainshock');
        end
        
        function Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            obj.FunctionCall={'radius','noiselevel','cleverness'};
            disp('sample.Calculate')
            steps=0:.1:2*pi;
            noise=obj.noiselevel*randn(1,length(steps));
            obj.Result.x = cos(steps) .* obj.radius + noise * obj.usenoise;
            noise=obj.noiselevel*randn(1,length(steps));
            obj.Result.y = sin(steps) .* obj.radius + noise * obj.usenoise;
            obj.Result.msg = 'calculation done!';
        end
        
        function plot(obj,varargin)
            % plots the results on the provided axes.
            if obj.cleverness
                obj.lstyle='^-';
            end
            
            f=obj.Figure('deleteaxes');
            
            obj.ax=axes(f);
            disp('sample.Plot')
            obj.hPlot=plot(obj.ax,obj.Result.x,obj.Result.y, obj.lstyle, varargin{:});
            xlabel(obj.ax,['zmapFunction plot: ', obj.plotlabel]);
        end
        
        function ModifyGlobals(~)
            % in this case, do nothing
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent)
            % create a menu item
            disp('MenuItem in sample');
            h=uimenu(parent,'Label','testmenuitem',...
                'Callback', @(~,~)sample_ZmapFunction()); %
        end
    end % static methods
    
end %classdef

%% Callbacks

% All callbacks should set values within the same field. Leave
% the gathering of values to the SetValuesFromDialog button.
