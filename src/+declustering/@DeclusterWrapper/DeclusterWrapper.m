classdef DeclusterWrapper < handle
		
	%This is a template to the so called MiniWrappers. The purpose of those
	%wrappers is to make conversion of old zmap calculation as easy as possible
	%(yeah this was said before, this will be easier, but also more limited).
	%All calculations done in this Wrapper are "on shots" the calculation can 
	%not be "redone" once the parameters are set.
	%Also there are selfcontaint and have no separation between GUI and calculation
	
	properties
		ListProxy
		Commander
		Datastore
		Keys
		Filterlist
		SendedEvents
		CalcRes
		CalcParameter
		CalcMode
		ErrorDialog
		ParallelMode
		StartCalc
		ResultGUI
		CalcTime
		PlotOptions
		BorderToogle
		CoastToogle
		PlotQuality
		LastPlot
		
	end

	events
		CalcDone

	end


	methods
	
	
		function obj = DeclusterWrapper(ListProxy,Commander,GUISwitch,CalcMode,CalcParameter)
			import mapseis.datastore.*;
				
			%A gui for the new mapseis Decluster algorithmen	
			
			%In this constructor everything is set, and the 
			obj.ListProxy=ListProxy;
			
			if isempty(Commander)
				obj.Commander=[];
				%go into manul mode, the object will be created but everything
				%has to be done manually (useful for scripting)
			else
			
				obj.Commander = Commander; 
				obj.ParallelMode=obj.Commander.ParallelMode;
				
				
				
				
			
							
				
				obj.ResultGUI=[];
				obj.PlotOptions=[];
				obj.BorderToogle=true;
				obj.CoastToogle=true;
				obj.PlotQuality = 'low';
				obj.LastPlot=[];
				obj.CalcMode=CalcMode;
				obj.CalcTime=[];
				
						
				%get the current datastore and filterlist and build zmap catalog
				obj.Datastore = obj.Commander.getCurrentDatastore;
				obj.Filterlist = obj.Commander.getCurrentFilterlist; 
				obj.Keys=obj.Commander.getMarkedKey;
				selected=obj.Filterlist.getSelected;
				obj.SendedEvents=selected;
				
				
				EveryThingGood=true;
				
				
				
				
				
				if EveryThingGood
					
					if ~isempty(CalcParameter)
						%Parameters are include, no default parameter will
						%be set
						obj.CalcParameter=CalcParameter;
					else
						obj.InitVariables
					end	
					
					
					
					switch CalcMode
					
						case 'Reasenberg'
							
							if GUISwitch
								
								%let the user modify the parameters
								obj.openCalcParamWindow;
								
								if obj.StartCalc
									
									%Calc
									obj.doTheCalcThing;
									
									%display all info 
									obj.DisplayResultInfo;
									
						
									
									
								end	
								
								
							end
						
						case 'MonteReasenberg'
						
						
						
						case 'Gardner-Knopoff'
							
							if GUISwitch
								
								%let the user modify the parameters
								obj.openCalcParamWindowGK;
								
								if obj.StartCalc
									
									%Calc
									obj.doTheCalcThingGK;
									
									%display all info 
									obj.DisplayResultInfo;
									
						
									
									
								end	
								
								
							end
						
						
						case 'SLIDER'
							if GUISwitch
								
								%let the user modify the parameters
								obj.openCalcParamWindowSLI;
								
								if obj.StartCalc
									
									%Calc
									obj.doTheCalcThingSLI;
									
									%display all info 
									obj.DisplayResultInfo;
									
						
									
									
								end	
								
								
							end
						
							
						case 'Viewer'
					
                        otherwise
                            error('unknown CalcMode');
						
					end
				
				end
				
			end
			
		end



		%additional methods used (external files)
		%----------------------------------------
		InitVariables(obj)

		openCalcParamWindow(obj)

		openCalcParamWindowGK(obj)
		
		openCalcParamWindowSLI(obj)
	
		doTheCalcThing(obj)

		doTheCalcThingMonte(obj)

		doTheCalcThingGK(obj)

		doTheCalcThingSLI(obj)

		DisplayResultInfo(obj)

		ClusterViewer(obj)


	end


end
