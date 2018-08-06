function [bResult] = gui_IsStringPositiveInteger(sInput, sMessage)

bResult = true;
Tmp = str2double(sInput);
if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
  errordlg([sMessage ' must be a positive integer value']);
  bResult = false;
end
