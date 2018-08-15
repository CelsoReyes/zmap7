function [fAverageStdDev] = kj_CalcOverallStdDev(params)
    % Avg standard deviation for catalog and polygon
    %
    % [fAverageStdDev] = kj_CalcOverallStdDev(params);
    % ---------------------------------------------------------
    % Determines the average standard deviation for a given catalog and
    %   for a given nodes-polygon. For every node with nMinimumNumber of
    %   earthquakes the mean standard deviation (using the
    %   number of earthquakes of this sample) will be calculated. The function
    %   returns the average value of the standard deviation of all nodes
    %
    % Input parameters:
    %   params.mPolygon           Polygon (defined by ex_selectgrid)
    %   params.bMap               Do the calculation for a map (true) or a cross-section (false)
    %   params.mCatalog           Earthquake catalog
    %   params.bNumber            Use constant number (true) or constant radius (false)
    %   params.nNumberEvents      Number of earthquakes if bNumber is true
    %   params.fRadius            Radius of gridnode if bNumber is false
    %   params.nMinimumNumber     Minimum number of earthquakes per node
    %
    % Output parameters:
    %   fAverageStdDev            Average standard deviation
    %
    % Danijel Schorlemmer
    % November 7, 2001
    
    report_this_filefun();
    
    % Initialize container
    vStdDev = [];
    
    % Step thru all polygon nodes
    for nNode = 1:length(params.mPolygon(:,1))
        x = params.mPolygon(nNode, 1);
        y = params.mPolygon(nNode, 2);
        
        if ~params.bMap
            [nRow, nColumn] = size(params.mCatalog);
            xsecx2 = params.mCatalog(:,nColumn);      % Length along cross-section
            xsecy2 = params.mCatalog.Depth;            % Depth of hypocenters
        end
        
        % Calculate distance from center point and sort with distance
        if params.bMap
            vDistances = sqrt(((params.mCatalog.Longitude-x)*cosd(y)*111).^2 + ((params.mCatalog.Latitude-y)*111).^2);
        else
            vDistances = sqrt(((xsecx2 - x)).^2 + ((xsecy2 + y)).^2);
        end
        [vTmp, vIndices] = sort(vDistances);
        mNodeCatalog = params.mCatalog(vIndices(:,1),:);
        
        % Select the events for calculation
        if params.bNumber
            % Use first nNumberEvents events
            mNodeCatalog = mNodeCatalog(1:params.nNumberEvents,:);
        else
            % Use all events within fRadius
            vDistances = (vDistances <= params.fRadius);
            mNodeCatalog = params.mCatalog.subset(vDistances);
        end
        
        % Determine the number of earthquakes in the sample
        nSampleSize = length(mNodeCatalog(:,1));
        
        % Calculate the average standard deviation for this samplesize
        if nSampleSize >= params.nMinimumNumber
            [fBValue, fStdDev] = calc_RandomBValue(params.mCatalog, nSampleSize, 500);
            vStdDev = [vStdDev; fStdDev];   % Store it
        end
    end % of for nNode
    
    % Return average value
    fAverageStdDev = nanmean(vStdDev);
end
