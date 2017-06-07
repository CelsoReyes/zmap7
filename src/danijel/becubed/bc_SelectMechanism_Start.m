function [mNewCatalog] = bc_SelectMechanism_Start(mCatalog)

% Default return value
mNewCatalog = nan;

% Invoke the user interface
hDialog = bc_SelectMechanism_Dialog;

% Analyze Output
if ~ishandle(hDialog)
  answer = 0;
else
  handles = guidata(hDialog);
  answer = handles.answer;
  % OK pressed
  if answer == 1
    % Get the user options
    nType = get(handles.cboMechanism, 'Value');
    fAngle = str2double(get(handles.txtAngle, 'String'));
    % Remove figure from memory
    delete(hDialog);
    % Create the new catalog
    [mNewCatalog] = bc_SelectMechanism(mCatalog, nType, fAngle);
  else
    % Remove figure from memory
    delete(hDialog);
  end
end

