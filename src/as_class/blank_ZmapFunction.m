classdef blank_ZmapFunction < ZmapFunction
    % description of this function
    %
    % in the function that generates the figure where this function can be called:
    %
    %     % create some menu items... 
    %     h=sample_ZmapFunction.AddMenuItem(hMenu,@()mycat) %create subordinate to menu item with handle hMenu
    %     % create the rest of the menu items...
    %
    %  once the menu item is clicked, then sample_ZmapFunction.interative_setup(true,true) is called
    %  meaning that the user will be provided with a dialog to set up the parameters,
    %  and the results will be automatically calculated & plotted once they hit the "GO" button
    %
    
    
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
            
            
            zdlg=ZmapDialog(...
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
            %  zdlg.AddBasicCheckbox : add checkbox that returns state, 
            %                          and may affect other control's enable states
            %  zdlg.AddBasicEdit : add basic edit field & edit field label combo
            %  zdlg.AddEventSelectionParameters : add section that returns how grid points
            %                                     may be evaluated
           
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
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,catalogfn)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','testmenuitem',...    CHANGE THIS TO YOUR MENUNAME
                'MenuSelectedFcn', @(~,~)blank_ZmapFunction(catalogfn())... CHANGE THIS TO YOUR CALLBACK
                );
        end
        
    end % static methods
    
end %classdef

%% Callbacks

% All callbacks should set values within the same field. Leave
% the gathering of values to the SetValuesFromDialog button.
