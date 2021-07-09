classdef cross_stress < ZmapVGridFunction
    % CROSS_STRESS calculate stress parameters along cross section   
    %
    % Parameters to be calculated:
    % fTS1     : Trend of Maximum compressive principal stress axis
    % fPS1     : Plunge of the Maximum compressive principal stress axis
    % fTS2     : Trend of Intermediate compressive principal stress axis
    % fPS2     : Plunge of the Intermediate compressive principal stress axis
    % fTS3     : Trend of Minimum compressive principal stress axis
    % fPS3     : Plunge of the Minimum compressive principal stress axis
    % fPhi     : Relative magnitude of principal stresses
    % fSigma   : Variance of stress tensor inversion
    %
    % updated: J. Woessner, 08.03.2004
    % turned into function by Celso G Reyes 2017, turned into class - 2019
    %
    %
    % viewer used to be :
    % view_xstress
    
    properties
        stress_method = 'michaels' % 1
        faultplane_strike = 0;  % Strike of fault plane (0-179.9999)
        
    end
    
    properties(Constant)
        PlotTag         = 'stressgrid [xsec]';
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'phi', 'phi', '';... % 1: mPhi 
            'S1Trend',  'S1Trend','deg';... % 2: mTS1
            'S1Plunge', 'S1Plunge','deg';...% 3: mPS1
            'S2Trend',  'S2Trend','deg';... % 4: mTS2
            'S2Plunge', 'S2Plunge','deg';...% 5: mPS2
            'S3Trend',  'S3Trend','deg';... % 6 mTS3
            'S3Plunge', 'S3Plunge','deg';... % 7 mPS3
            'Variance', 'Variance','';... % 8 mVariance
            'Beta', 'Angular misfit (Beta)', 'deg'; ... %11 mBeta
            'BetaStd', 'Angular misfit Std', 'deg'; ... %12 mbetaStd
            'Tau', 'Tau spread','deg'; ... % 13 mTau, mAvgTau
            'TauStd', 'Tau spread Std', 'deg'; ... %14 mTauStd
            'TauRatio', 'Tau Ratio', ''; ... %15 mTauRatio, mTauFit
            'TS1Rel', 'Trend S1 relative to fault strike', 'deg'; ... %16 mTS1Rel
            }, 'VariableNames', {'Names','Descriptions','Units'});
        
        CalcFields = {'phi',...
            'S1Trend',  'S1Plunge',...
            'S2Trend',  'S2Plunge',...
            'S3Trend',  'S3Plunge',...
            'Variance',...
            'Beta', 'BetaStd', 'Tau', 'TauStd', 'TauRatio'};
        
        ExtDir = fullfile(ZmapGlobal.Data.hodi, 'external');
        ParameterableProperties = ["faultplane_strike"];
        References="Michael A.J.. Determination of stress from slip data: faults and folds, J. geophys. Res. , 1984, vol. 89 (pg. 11 517-11 526)"
    end
    
    methods
        function obj=cross_stress(zap, varargin)
            % CROSS_STRESS
            % obj = CROSS_STRESS() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CROSS_STRESS(ZAP) where ZAP is a ZmapAnalysisPkg
            
            obj@ZmapVGridFunction(zap, 'S1Trend');
            
            report_this_filefun();
            unimplemented_error()
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            
            %% make the interface
            zdlg = ZmapDialog();
            
            zdlg.AddHeader('Choose stuff [THIS STILL NOT TOTALLY IMPLEMETNED]');
            
    
            labelList2={'Michaels method'};

            zdlg = ZmapDialog();

            zdlg.AddHeader('Stress Variance Parameters');
            zdlg.AddPopup('stress_method', 'stress tensor inversion method:',labelList2,1,...
                'Choose the calculation method for stress tensor inversion');
            zdlg.AddEdit('faultplane_strike','Strike [deg] of fault plane',obj.faultplane_strike,'Strike');
            zdlg.Create('Name', 'stress variance parameters [xsec]',obj,'OkFcn', @obj.doIt);
        end
        
        function results = Calculate(obj)
            % once the properties have been set, either by the constructor or by interactive_setup
            % get the grid-size interactively and calculate the values in the grid by sorting the
            % seismicity and selecting the appropriate neighbors to each grid point
            
            obj.gridCalculations(@calculation_function, @modifier);
            
            if nargout
                results=obj.Result.values;
            end
            
            function tb = modifier(tb)
                % Compute equivalent angles for fTS1 relative to strike
                tb.TS1Rel = calc_Rel2Strike(obj.faultplane_strike, tb.S1Trend);

                % Compute equivalent angles for fTS1 relative to north
                vSel = tb.S1Trend < 0;
                tb.S1Trend(vSel) = tb.S1Trend(vSel) + 180;
            end
                
            function out = calculation_function(catalog)
                % calulate values at a single point
                
                % Check for minimum number of events
                if length(catalog.Count) < Nmin
                    out = [NaN NaN NaN NaN NaN NaN NaN NaN  NaN NaN NaN NaN NaN];
                    return
                end
                % Take the focal mechanism from actual catalog
                % tmpi-input: [dip direction (East of North), dip , rake (Kanamori)]
                dip_dipdir_rake = catalog.getAddon('MomentTensor');
                maxThings = min(size(dip_dipdir,1), 999);
                tmpi = dip_dipdir_rake(1:maxThings, [2,1,3]); %reorder and take maximum
                % Create file for inversion
                fid = fopen('data2','w');
                fprintf(fid,'Inversion data  \n');
                fprintf(fid,'%7.3f  %7.3f  %7.3f\n',tmpi');
                fclose(fid);

                % slick calculates the best solution for the stress tensor according to
                % Michael(1987): creates data2.oput
                slick_program = append_system_specific_postfix('slick');
                slfast_program = append_system_specific_postfix('slfast');
                system([fullfile(ZG.hodi, slick_program), ' data2 '])


                % Get data from data2.oput
                sFilename = 'data2.oput';
                [fBeta, fStdBeta, fTauFit, fAvgTau, fStdTau] = import_slickoput(sFilename);

                % Delete existing data2.slboot
                sData2 = fullfile(ZG.hodi, 'external', 'data2.slboot');
                delete(sData2);

                % Stress tensor inversion
                system([fullfile(ZG.hodi, 'external', slfast_program),' data2']);

                sGetFile = fullfile(ZG.hodi, 'external', 'data2.slboot');
                external_results = load(sGetFile);
                d0 = external_results.data2;

                % Result matrix containing
                % Phi fTS1 fPS1 fTS2 fPS2 fTS3 fPS3 Variance
                out = [d0(2,1:7) d0(1,1) fBeta fStdBeta fAvgTau fStdTau fTauFit];
            end
        end

    end
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'stress map [xsec]';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XZfun.cross_stress(zapFcn()),...
                varargin{:});
        end
    end
end
