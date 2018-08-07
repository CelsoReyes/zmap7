classdef fix_caxis < ZmapFunction
    % fix_caxis sets the colorbar and sets min/max values
    
    properties
        orientation; % index of the Orientations
        maxval;
        minval;
        freeze=false;
    end
    
    properties(Constant)
        PlotTag='fixcaxis';
        Orientations={'do not draw','vert','horiz'}
        
    end
    
    
    methods
        function obj=fix_caxis(valueMap, orientation, varargin) %CONSTRUCTOR
            % fix_caxis() %
            % fix_caxis(valueMap);
            % fix_caxis(valueMap, orientation) where orientation is '' {no colorbar is drawn},
            % 'horiz' {draw/redraw horizontal colorbar}, 'vert' {draw/redraw vertical colorbvar}
            % fix_caxis(valueMap, orientation, minVal, maxVal, freeze);
            %
            % if valueMap exists, but is empty, then ZGvalueMap is used.
            
            % depending on whether parameters were provided, either run automatically, or
            % request input from the user.
            
            ZG=ZmapGlobal.Data;
                
            if ~exist('orientation','var')
                orientation='do not draw';
            end
            if isempty(valueMap)
                valueMap=ZG.valueMap;
            end
            [~,obj.orientation] = ismember(orientation,obj.Orientations);
            
            
            if nargin==5
                obj.minval=varargin{1};
                obj.maxval=varargin{2};
                obj.freeze=logical(varargin{3});
                obj.doIt();
            elseif nargin==0
                obj.minval=ZG.freeze_colorbar.minval;
                obj.maxval=ZG.freeze_colorbar.maxval;
                obj.freeze=ZG.freeze_colorbar.freeze;
                obj.orientation='';
                obj.InteractiveSetup();
            elseif nargin>=1
                obj.maxval = max(valueMap(:),[],'omitnan');
                obj.minval = min(valueMap(:),[],'omitnan');
                obj.InteractiveSetup();
            end
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            
            zdlg=ZmapDialog(...
                obj,...  pass it a handle that it can change when the OK button is pressed.
                @obj.doIt...  if OK is pressed, then this function will be executed.
                );
            
            zdlg.AddPopup('orientation','Choose Colorbar Orientation',obj.Orientations,1,...
                'If an orientation is chosen, the colorbar will be (re)drawn in that position');
            zdlg.AddEdit('minval','Please input minimum of z-axis',obj.minval,...
                'Will be lower limit for clim');
            zdlg.AddEdit('maxval','Please input maximum of z- (or b-) values',obj.maxval,...
                'Will be upper limit for clim');
            zdlg.AddCheckbox('freeze','Freeze Colorbar?',false,{},...
                'If true, then the colorbar will be frozen to these values on various maps');
            zdlg.Create('Vertical Axis Control');
            % The dialog runs. if:
            %  OK is pressed -> assigns
        end
        
        function Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup

            % check pre-conditions
            assert(obj.orientation ~= 0,'Invalid colorbar orientation choice');


            obj.FunctionCall={'','orientation','minval','maxval','freeze'};
            % results of the calculation should be stored in fields belonging to obj.Result
            
            obj.Result.Data=[];
            
        end
        
        function plot(obj,varargin)
            % plots the results somewhere
            cbOrient=obj.Orientations{obj.orientation};
            f=gcf;
            
            obj.ax=findobj(f,'Type','axes');
            if ~isempty(obj.ax)
                caxis(obj.ax,[obj.minval obj.maxval]);
                return
            end
            if ismember(cbOrient, {'horiz','vert'})
                h5=findobj(f,'Type','ColorBar');
                delete(h5);
                h5 = colorbar(f,cbOrient);
                set(h5,'Pos',[0.35 0.07 0.4 0.02],...
                    'FontWeight','bold',...
                    'TickDir','out',...
                    'FontSize',ZmapGlobal.Data.fontsz.s,...
                    'Linewidth',1.5);
            end
        end
        
        function ModifyGlobals(obj)
            % change the ZmapGlobal variable, if appropriate
            % obj.ZG.SOMETHING = obj.Results.SOMETHING
            ZG=ZmapGlobal.Data;
            freeze_colorbar=struct('minval',obj.minval,...
                'maxval',obj.maxval,...
                'freeze',logical(obj.freeze));
            
            ZG.freeze_colorbar=freeze_colorbar;
        end
        
    end %methods
    
    methods(Static)
        function h=AddMenuItem(parent,catalogfn)
            % create a menu item that will be used to call this function/class
            
            h=uimenu(parent,'Label','fix c-axes',...    CHANGE THIS TO YOUR MENUNAME
                MenuSelectedField(), @(~,~)fix_caxis(catalogfn())... CHANGE THIS TO YOUR CALLBACK
                );
        end
        function ApplyIfFrozen(ax)
            ZG=ZmapGlobal.Data;
            if ZG.freeze_colorbar.freeze
                caxis(ax,[ZG.freeze_colorbar.minval, ZG.freeze_colorbar.maxval]);
            end
        end
        
    end % static methods
    
end %classdef
