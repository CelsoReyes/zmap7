function [bResult] = gui_IsStringPositiveFloat(sInput, sMessage)

bResult = true;
Tmp = str2double(sInput);
if (isnan(Tmp) | (Tmp <= 0))
  errordlg([sMessage ' must be a positive float value']);
  bResult = false;
end
