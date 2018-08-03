function [uOutput] = import_california_fm(nFunction, sFilename)
% function [uOutput] = import_california_fm(nFunction, sFilename);
% ----------------------------------------------------------------
% Function to import NCEDC NCSN-FPFIT catalog from the UCB, CA, and
% the Hauksson relocated catalog for southern California.
% See:
% http://quake.geo.berkeley.edu
% http://www.data.scec.org/ftp/catalogs/hauksson/Socal_focal/
%
% updated: 17.05.2005, Danijel Schorlemmer
% schorlemmer@sed.ethz.ch

% Counter for double events
nCount = 0;

% Filter function switchyard
if nFunction == FilterOp.getDescription
  uOutput = 'California focal mechanism catalogs (NCEDC NCSN-FPFIT/SCSN Hauksson) raw format/multiple solutions eliminated';
elseif nFunction == FilterOp.importCatalog
  % Read formatted data
  mData = textread(sFilename, '%s', 'delimiter', '\n', 'whitespace', '');
  % Create empty catalog
  uOutput = zeros(length(mData), 24);
  % Loop thru all lines of catalog and convert them
  for i = 1:length(mData)
    if rem(i,100) == 0
      % Notify the user every 100 processed events
      disp([num2str(i) ' of ' num2str(length(mData)) ' events processed.']);
    end
    try
      % Replace whitespace in first column with '0'
      l = find(mData{i} == ' ');
      mData{i}(l) = '0';
      % Read values into catalog
      uOutput(i,1) = -str2num(mData{i}(29:32)) - str2num(mData{i}(34:38))/60 ;  % Longitude
      uOutput(i,2) =  str2num(mData{i}(20:22)) + str2num(mData{i}(24:28))/60 ;  % Latitude
      uOutput(i,3) = str2num(mData{i}(1:4));      % Year
      uOutput(i,4) = str2num(mData{i}(5:6));      % Month
      uOutput(i,5) = str2num(mData{i}(7:8));      % Day
      uOutput(i,6) = str2num(mData{i}(48:52));    % Magnitude
      uOutput(i,7) = str2num(mData{i}(39:45));    % Depth
      uOutput(i,8) = str2num(mData{i}(10:11));    % Hour
      uOutput(i,9) = str2num(mData{i}(12:13));    % Minute
      uOutput(i,10) = str2num(mData{i}(15:19));   % Second
      uOutput(i,11) = nan;                        % Reserved for cross-section values
      uOutput(i,13) = str2num(mData{i}(84:86));   % Dip direction (Plane 1)
      uOutput(i,12) = uOutput(i,13) - 90;         % Strike (Plane 1)
      uOutput(i,12) = mod(uOutput(i,12) + 360, 360);
      uOutput(i,14) = str2num(mData{i}(88:89));   % Dip (Plane 1)
      uOutput(i,15) = str2num(mData{i}(90:93));   % Rake (Plane 1)
      % Second nodal plane
      % uOutput(i,16) = Strike (Plane 2)
      % uOutput(i,17) = Dip direction (Plane 2)
      % uOutput(i,18) = Dip (Plane 2)
      % uOutput(i,19) = Rake (Plane 2)
      [uOutput(i,16), uOutput(i,18), uOutput(i,19), uOutput(i,17)] ...
        = ComputeSecondPlane(uOutput(i,12), uOutput(i,14), uOutput(i,15));
      uOutput(i,20) = str2num(mData{i}(72:74));   % Horizontal location error [km]
      uOutput(i,21) = str2num(mData{i}(77:79));   % Vertical location error [km]
      uOutput(i,22) = str2num(mData{i}(96:99));   % Solution misfit value. 0=perfect fit, 1=perfect misfit (never exceeds 0.5 in reality).
      uOutput(i,23) = str2num(mData{i}(132:141)); % Event ID # found in Hypoinverse archive file
      uOutput(i,24) = str2num(mData{i}(111:114)); % (STDR) Station distribution ratio (0-1). Lower numbers indicate data lie near nodal planes.
      uOutput(i,25) = str2num(mData{i}(101:103)); % Number of first motion observations used in solution
      uOutput(i,26) = str2num(mData{i}(122:123)); % Maximum half-width of 90% confidence range of strike
      uOutput(i,27) = str2num(mData{i}(125:126)); % Maximum half-width of 90% confidence range of dip
      uOutput(i,28) = str2num(mData{i}(128:129)); % Maximum half-width of 90% confidence range of rake
      % In case of multiple solutions, take only the best solution
      try
        if uOutput(i,23) == uOutput(i-1,23)       % Same event?
            nCount=nCount+1;
          if uOutput(i,24) > uOutput(i-1,24)      % Higher STDR?
            uOutput(i-1,1) = nan;                 % Invalidate the former event
          elseif uOutput(i,24) == uOutput(i-1,24) % Same STDR?
            if uOutput(i,22) < uOutput(i-1,22)    % Better solution misfit?
              uOutput(i-1,1) = nan;               % Invalidate the former event
            else                                  % Worse or equal solution misfit?
              uOutput(i,:) = uOutput(i-1,:);      % Copy the former event into current one
              uOutput(i-1,1) = nan;               % Invalidate the former event
            end
          else                                    % Lower STDR?
            uOutput(i,:) = uOutput(i-1,:);        % Copy the former event into current one
            uOutput(i-1,1) = nan;                 % Invalidate the former event
          end
        end
      catch
      end
      %Create decimal year
      uOutput(i,3) = decyear([uOutput(i,3) uOutput(i,4) uOutput(i,5) uOutput(i,8) uOutput(i,9) uOutput(i,10)]);
    catch
      disp(['Import: Problem in line ' num2str(i) ' of ' sFilename '. Line ignored.']);
      uOutput(i,:) = nan;
    end
  end
  % Delete all invalidated events from catalog
  vSel = isnan(uOutput(:,1));
  uOutput(vSel,:) = [];
end

% --- Helper function

function [fStrike2, fDip2, fRake2, fDipDir2] = ComputeSecondPlane(fStrike1, fDip1, fRake1)

% Do not modify strike (Dip and rake need to be modified in order to
% minimize computational errors)
fDip1 = fDip1 + 0.000001;
fRake1 = mod((fRake1 + 0.000001) + 360, 360);
[fStrike2, fDip2, fRake2, fDipDir2, nError] = focal_pl2pl(fStrike1, fDip1, fRake1);
