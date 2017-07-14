% This is the main message window of zmap
% It is use to display messages and input parameters
%TODO Remove this file
error('this is no longer used')
report_this_filefun(mfilename('fullpath'));

%
% make the interface
%
% Find out of figure already exists
%

% Set up the Seismicity Map window Enviroment
%
mess = figure();
set(mess,...
    'Name','Message Window',...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'Visible','off', ...
    'Position',[ ZG.welcome_pos ZG.welcome_len ]);


%  set(gcf,'Color',[0.8 0.8 0.8])

set(gca,'visible','off');
zmap_message_center.set_message()
set(mess,'visible','on');
done()
