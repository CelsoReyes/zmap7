function openCalcParamWindow(obj)
		%Here a window for the calculation parameters should be created
		%I suggest using the inputsdlg function 
		
		
		
		Title = 'Reasenberg Decluster ';
		Prompt={'Min. forward time (taumin):', 'Tau_min';...
			'Max. forward time (taumax):', 'Tau_max';...
			'Radius factor (rfact):','RadiusFactor';...
			'Effective mag. cutoff (xmeff):','XMagEff';...
			'Mag. factor (xk):','XMagFactor';...
			'Probability of Observation (P):','ProbObs';...
			'Epicenter error (err):','EpiError';...
			'Depth error (derr):','DepthError'};
			
				
				
				
			
			
		%taumin
		Formats(1,1).type='edit';
		Formats(1,1).format='float';
		Formats(1,1).limits = [0 9999];
		
		%taumax
		Formats(2,1).type='edit';
		Formats(2,1).format='float';
		Formats(2,1).limits = [0 9999];
		
		%rfact
		Formats(3,1).type='edit';
		Formats(3,1).format='float';
		Formats(3,1).limits = [0 9999];
		
		%xmeff
		Formats(4,1).type='edit';
		Formats(4,1).format='float';
		Formats(4,1).limits = [0 9999];
		
		%xk
		Formats(5,1).type='edit';
		Formats(5,1).format='float';
		Formats(5,1).limits = [0 9999];
		
		%P
		Formats(6,1).type='edit';
		Formats(6,1).format='float';
		Formats(6,1).limits = [0 1];
		
		%err
		Formats(7,1).type='edit';
		Formats(7,1).format='float';
		Formats(7,1).limits = [0 9999];
			
		%derr
		Formats(8,1).type='edit';
		Formats(8,1).format='float';
		Formats(8,1).limits = [0 9999];
			
			
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
