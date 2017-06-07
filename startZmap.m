function startZmap
    %evalin('test','zmap');
    zmap
    %evalin('base','a=a');
    save('tempout.mat','a');
	evalin('base','load(''tempout.mat'')');;
end
