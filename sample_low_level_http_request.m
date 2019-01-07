% dealing with fdsn data more-or-less directly
% this is a temporary script, and should be rolled into the 
% FDSN import routines
% with the anticipation that matlab.net.http.ProgressMonitor
% will be used to provide feedback.

% U = matlab.net.URI('http://service.iris.edu/fdsnws/event/1/query?starttime=2018-01-11T00:00:00&orderby=time&format=text&nodata=404');
tic
U = matlab.net.URI('http://service.iris.edu/fdsnws/event/1/query?starttime=2018-09-11T00:00:00&orderby=time&format=text&nodata=404');
method = matlab.net.http.RequestMethod.GET;
type1 = matlab.net.http.MediaType('text/*');
acceptField = matlab.net.http.field.AcceptField([type1]);
contentTypeField = matlab.net.http.field.ContentTypeField('text/plain');
header = [acceptField contentTypeField];
request = matlab.net.http.RequestMessage(method,header);

consumer=matlab.net.http.io.StringConsumer;

[resp,req,hist] = request.send(U,matlab.net.http.HTTPOptions('SavePayload',true,'ProgressMonitorFcn',@MyProgressMonitorNew,'UseProgressMonitor',true),consumer);
% show(request)
% resp.show

% if there is an error, it would be shown in hist.Response.Body.Data
ss=strsplit(string(char(resp.Body.Data')),newline)';
numel(ss)
%%
f=fopen('junkk.dat','w');
fprintf(f,"%s",resp.Body.Data); %resp.Body.Payload
fclose(f);
%%
ZG.primeCatalog = import_fdsn_event(1,'junk.dat')
% ZmapMainWindow(ZG.primeCatalog)
toc
