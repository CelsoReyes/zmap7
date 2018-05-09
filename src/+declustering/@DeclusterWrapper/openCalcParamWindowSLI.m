function openCalcParamWindowSLI(obj)
		%Here a window for the calculation parameters should be created
		%I suggest using the inputsdlg function 
		
		
		
		Title = 'SLIDER Decluster ';
		Prompt={'Selection Method:', 'Sli_Type';...
			'Min. Mainshock Magnitude:','MainMag';...
			'Time before Eq (d):', 'BackTime';...
			'Time after Eq (d):', 'ForeTime';...
			'Min. search radius (km):', 'MinRad';...
			'Mag. radius scaler:', 'MagRadScale';...
			'Mag. radius constant:','MagRadConst'};
			
				
		LabelList2 =  {	'Magnitude';...
				'Time'}; 		
				
		
		%Sli Method
		Formats(1,1).type='list';
		Formats(1,1).style='popupmenu';
		Formats(1,1).items=LabelList2;
		
		
		%min MainMag 
		Formats(2,1).type='edit';
		Formats(2,1).format='float';
		Formats(2,1).limits = [-99 99];
					
		%Time before eq
		Formats(3,1).type='edit';
		Formats(3,1).format='float';
		Formats(3,1).limits = [0 9999];
		
		%Time after eq
		Formats(4,1).type='edit';
		Formats(4,1).format='float';
		Formats(4,1).limits = [0 9999];
		
		%Min Search Radius
		Formats(5,1).type='edit';
		Formats(5,1).format='float';
		Formats(5,1).limits = [0 9999];
		
		%Mag Search Radius Scaler
		Formats(6,1).type='edit';
		Formats(6,1).format='float';
		Formats(6,1).limits = [0 9999];
		
		%Mag Search Radius Constant
		Formats(7,1).type='edit';
		Formats(7,1).format='float';
		Formats(7,1).limits = [0 9999];
			
			
		%%%% SETTING DIALOG OPTIONS
		Options.WindowStyle = 'modal';
		Options.Resize = 'on';
		Options.Interpreter = 'tex';
		Options.ApplyButton = 'off';
		
		
		%open the dialog window
		[NewParameter,Canceled] = inputsdlg(Prompt,Title,Formats,obj.CalcParameter,Options); 
		
		
		obj.CalcParameter=NewParameter;
		
			
			
		if Canceled==1
			obj.StartCalc=false;
		else
			obj.StartCalc=true;
		end
		
		
			
end		
