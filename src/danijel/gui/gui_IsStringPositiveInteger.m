function [bResult] = gui_IsStringPositiveInteger(sInput, sMessage)

bResult = 1;
Tmp = str2double(sInput);
if (isnan(Tmp) | (Tmp ~= round(Tmp)) | (Tmp <= 0))
  errordlg([sMessage ' must be a positive integer value']);
  bResult = 0;
end
