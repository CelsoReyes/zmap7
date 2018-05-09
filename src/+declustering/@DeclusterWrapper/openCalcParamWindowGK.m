function openCalcParamWindowGK(obj)
		%Here a window for the calculation parameters should be created
		%I suggest using the inputsdlg function 
		
		
		
		Title = 'Gardner-Knopoff Decluster ';
		Prompt={'Window Method:', 'GK_Method';...
			'Force MainShock:', 'GK_SetMain'};
			
				
		LabelList2 =  {	'Gardener & Knopoff (table), 1974';...
				'Gardener & Knopoff (formula), 1974'; ...
				'Gruenthal pers. communication'; ...
				'Urhammer, 1986'}; 		
				
		
		%Method
		Formats(1,1).type='list';
		Formats(1,1).style='popupmenu';
		Formats(1,1).items=LabelList2;
		
					
		%SetMain
		Formats(2,1).type='check';
			
			
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