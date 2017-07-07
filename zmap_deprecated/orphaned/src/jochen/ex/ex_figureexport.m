function [options] = ex_figureexport(hFigure,sFilename,sPrintOpt,sOrientation)
% function [options] = ex_figureexport(hFigure,sFilename,sPrintOpt, sOrientation)
% ------------------------------------------------------
% Saves a Matlab figure file and creates an eps figure
%
% 14.09.2004,jochen.woessner@sed.ethz.ch

% Set defaults
if nargin == 0, disp('Specify figure handle!'); return; end
if nargin < 2, sPrintOpt = 'jpg'; sFilename = 'Output', sOrientation = 'Portrait'; end
if nargin < 3, sFilename = 'Output', sOrientation = 'Portrait';end
if nargin < 4, sOrientation = 'Portrait';end

% Get figure properties
options=get(hFigure);

% Set options
options.PaperType = 'A4';
options.PaperUnits = 'centimeters';
option.PaperSize = [21 29.7];
options.PaperOrientation = sOrientation;

set(gcf,'PaperType','A4','PaperUnits','centimeters','PaperSize',[20.9 29.7],'PaperOrientation',sOrientation,'renderer','painters');
% set(gca,'Linewidth',2,'Fontweight','bold','FontSize',14);
% set(get(gca,'XLabel'),'FontSize',14,'Fontweight','bold');
% set(get(gca,'YLabel'),'FontSize',14,'Fontweight','bold');

if ~exist('sPrintOpt','var')
    sPrintOpt = 'jpg';
end

switch sPrintOpt
    case {'fig'}
        % Save Matlab figure
        saveas(hFigure,sFilename);
    case {'psc'}
        % Export ps-figure
        sPrintName = [sFilename '.ps'];
        print('-dpsc','-cmyk',sPrintName);
    case {'eps'}
        % Export eps-figure
        sPrintName = [sFilename '.eps'];
        print('-depsc','-tiff','-r100','-cmyk',sPrintName);
    case {'figeps'}
        % Save Matlab figure
        saveas(hFigure,sFilename);
        % Export eps-figure
        sPrintName = [sFilename '.eps'];
        print('-depsc','-tiff','-r100','-cmyk',sPrintName);
    case {'figepsjpg'}
        % Save Matlab figure
        saveas(hFigure,sFilename);
        % Export eps-figure
        sPrintName = [sFilename '.eps'];
        print('-depsc2','-tiff','-r100','-cmyk',sPrintName);
        % Jpeg
        sPrintName1 = [sFilename '.jpg'];
        print('-djpeg100','-cmyk',sPrintName1);
    case {'tif'}
        % Export tiff-figure
        sPrintName = [sFilename '.tif'];
        print('-dtiff','-r300','-cmyk',sPrintName);
    case {'figtif'}
        % Save Matlab figure
        saveas(hFigure,sFilename);
        % Export tiff-figure
        sPrintName = [sFilename '.tif'];
        print('-dtiff','-r300','-cmyk',sPrintName);
    otherwise % jpg
        sPrintName1 = [sFilename '.jpg'];
        print('-djpeg100','-cmyk',sPrintName1);
end
