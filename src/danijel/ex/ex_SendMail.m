function ex_SendMail(sRecipient, sMessage, sHostname)

if ~exist('sHostname', 'var')
  [s, sHostname] = unix(['echo $HOSTNAME']);
end
unix(['mail -s ' char(39) sHostname ' - ' sMessage char(39) ' ' sRecipient ' < /dev/null']);
