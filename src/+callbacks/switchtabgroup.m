function switchtabgroup(~,~, disallowedH)
    % only valid for tabs
    meObj = gco;
    meGroup = meObj.Parent;
    if meGroup==disallowedH
        errordlg('Sorry. Cannot move this tab.');
        return
    end
    meGroupContainer = meGroup.Parent;
    optionH=findobj(meGroupContainer.Children,'flat','Type','uitabgroup');
    optionH(optionH==disallowedH)=[];
    zdlg=ZmapDialog;
    zdlg.AddPopup('moveto','Move to:',string({optionH.Tag}),optionH==meObj.Parent,'');
    [res,ok]=zdlg.Create('Name','move tab');
    if ok
        meObj.Parent=optionH(res.moveto);
    end
end