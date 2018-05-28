classdef NDK
    % NDK works with NDK files can convert it to a ZmapCatalog
    %
    % from : https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained
    %
    % CMT files for download at: http://www.globalcmt.org/CMTfiles.html
    %
    % CMT reference:
    %   Dziewonski, A. M., T.-A. Chou and J. H. Woodhouse, Determination of earthquake source parameters from waveform data for studies of global and regional seismicity, J. Geophys. Res., 86, 2825-2852, 1981. doi:10.1029/JB086iB04p02825
    %   Ekström, G., M. Nettles, and A. M. Dziewonski, The global CMT project 2004-2010: Centroid-moment tensors for 13,017 earthquakes, Phys. Earth Planet. Inter., 200-201, 1-9, 2012. doi:10.1016/j.pepi.2012.04.002
    properties
        allNDKs table
        
        % TypeOfSourceInvertedFor is
        %"CMT: 0" - general moment tensor;
        %"CMT: 1" - moment tensor with constraint of zero trace (standard);
        %"CMT: 2" - double-couple source.
        
        % from line 3 of NDK format : CMT info (2)
        % Centroid_Time is  wrt reference time
        
        % CentroidDepthType is one of FREE, FIX, BODY
        
        % from line 4 of NDK format : CMT info (3)
        % ExponentForAllMomentValues most all moment measurements need to be multipleid by exponent
        %Mrr % r is up
        %Mtt % t is south
        %Mpp % p is east
    end
    
    methods
        function obj = NDK(ndktext)
            %
            %
            % parsing based on documentation found at :
            % https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained
            
            if nargin==0 || isempty(ndktext)
                return
            end
            if ischar(ndktext) && isvector(ndktext)
                ndktext=splitlines(strip(ndktext));
            end
            obj=obj.fillLine1(strjoin(ndktext(1:5:end),newline));
            obj=obj.fillLine2(strjoin(ndktext(2:5:end),newline));
            obj=obj.fillLine3(strjoin(ndktext(3:5:end),newline));
            obj=obj.fillLine4(strjoin(ndktext(4:5:end),newline));
            obj=obj.fillLine5(strjoin(ndktext(5:5:end),newline));
            
            
            
        end
        function obj = fillLine1(obj,s)
            % make sure reference catalog is not empty, otherwise textscan will choke
            noCat = strfind(s,[newline '    ']);
            s(noCat+1)='-';
            s(noCat+2)='-';
            s(noCat+3)='-';
            
            % make sure location is not empyt, otherwise textscan will choke
            sidexes = 57:81:numel(s);
            no_location= s(sidexes)==' ';
            s(sidexes(no_location))='-';
            % NDK's exist with 60 seconds. datetime chokes on this. Fix it.
            sidexes = 23:81:numel(s);
            add_a_minute = s(sidexes)=='6';
            s(sidexes(add_a_minute))='0';
            
            [c,POS]=textscan(s,'%4C %{uuuu/MM/DD}D %{HH:mm:ss.s}D %f %f %f %f %f %24c');
            obj.allNDKs.HypocenterReferenceCatalog=c{1};
            obj.allNDKs.ReferenceEventDateTime =c{2} + timeofday(c{3}) + minutes(add_a_minute(:));
            obj.allNDKs.Latitude = c{4};
            obj.allNDKs.Longitude=c{5};
            obj.allNDKs.Depth=c{6};
            obj.allNDKs.ReportedMagnitudes = [c{7},c{8}];
            obj.allNDKs.GeographicalLocation=categorical(string(c{9}));
        end
        
        function obj = fillLine2(obj,s)
            
            c = textscan(s, '%16s B:%d %d %d S:%d %d %d M:%d %d %d CMT:%C %5C:%f');
            
            % c is now a 1x13 cell, each cell is a field, and contains an array with one item per NDK
            obj.allNDKs.CMTEventName=c{1};
            obj.allNDKs.LPBodyWaves_NumStationsUsed=c{2};
            obj.allNDKs.LPBodyWaves_NumComponentsUsed=c{3};
            obj.allNDKs.LPBodyWaves_ShortestPeriodUsed=c{4};
            obj.allNDKs.IntermedPSurfaceWaves_NumStationsUsed=c{5};
            obj.allNDKs.IntermedPSurfaceWaves__NumComponentsUsed=c{6};
            obj.allNDKs.IntermedPSurfaceWaves_ShortestPeriodUsed=c{7};
            obj.allNDKs.LPMantleWaves_NumStationsUsed=c{8};
            obj.allNDKs.LPMantleWaves__NumComponentsUsed=c{9};
            obj.allNDKs.LPMantleWaves_ShortestPeriodUsed=c{10};
            obj.allNDKs.TypeOfSourceInvertedFor=c{11};
            obj.allNDKs.MomentRateFunctionType=c{12};
            obj.allNDKs.MomentRateFunctionDuration=c{13};
        end
        
        function obj = fillLine3(obj,s)
            
            [c, POS] = textscan(s, 'CENTROID: %f %f %f %f %f %f %f %f %C %c-%14c');
            obj.allNDKs.Centroid_Time =c{1};% wrt reference time
            obj.allNDKs.Centroid_TimeStderr = c{2};
            obj.allNDKs.Centroid_Lat = c{3};
            obj.allNDKs.Centroid_LatStderr = c{4};
            obj.allNDKs.Centroid_Lon = c{5};
            obj.allNDKs.Centroid_LonStderr = c{6};
            obj.allNDKs.Centroid_Depth = c{7};
            obj.allNDKs.Centroid_DepthStderr = c{8};
            obj.allNDKs.CentroidDepthType = c{9}; % one of FREE, FIX, BODY
            obj.allNDKs.TimeStampPrefix = c{10};
            obj.allNDKs.TimeStamp = c{11};
        end
        
        %from line 3 of NDK format : CMT info (2)
        
        
        function obj = fillLine4(obj,s)
            
            [c, POS] = textscan(s, '%d %f %f %f %f %f %f %f %f %f %f %f %f');
            % from line 4 of NDK format : CMT info (3)
            obj.allNDKs.ExponentForAllMomentValues=c{1};
            obj.allNDKs.Mrr=c{2}; % r is up
            obj.allNDKs.MrrStderr=c{3};
            obj.allNDKs.Mtt=c{4}; % t is south
            obj.allNDKs.MttStderr=c{5};
            obj.allNDKs.Mpp=c{6}; % p is east
            obj.allNDKs.MppStderr=c{7};
            obj.allNDKs.Mrt=c{8};
            obj.allNDKs.MrtStderr=c{9};
            obj.allNDKs.Mrp=c{10};
            obj.allNDKs.MrpStderr=c{11};
            obj.allNDKs.Mtp=c{12};
            obj.allNDKs.MtpStderr=c{13};
        end
        
        function obj = fillLine5(obj,s)
            [c,POS] = textscan(s, '%3C %f %d %d %f %d %d %f %d %d %f %d %d %d %d %d %d');
            
            obj.allNDKs.VersionCode=c{1};
            obj.allNDKs.MTEigenvalue=[c{2} c{3} c{4}];
            obj.allNDKs.MTPlunge=[c{5} c{6} c{7}];
            obj.allNDKs.MTAzimuth=[c{8} c{9} c{10}];
            obj.allNDKs.ScalarMoment=c{11}; % needs to be multiplied by exponent
            obj.allNDKs.Strike_NodalPlane1=c{12};
            obj.allNDKs.Dip_NodalPlane1=c{13};
            obj.allNDKs.Rake_NodalPlane1=c{14};
            obj.allNDKs.Strike_NodalPlane2=c{15};
            obj.allNDKs.Dip_NodalPlane2=c{16};
            obj.allNDKs.Rake_NodalPlane2=c{17};
        end
        
        function c = toZmapCatalog(obj)
            c=ZmapCatalog;
            c.Name='ndk';
            c.Longitude=obj.allNDKs.Longitude;
            c.Latitude=obj.allNDKs.Latitude;
            c.Depth=obj.allNDKs.Depth;
            c.Date=obj.allNDKs.ReferenceEventDateTime;
            c.Magnitude=obj.allNDKs.ReportedMagnitudes(:,1);
            c.MagnitudeType=repmat('unk',size(c.Magnitude));
            mt=obj.allNDKs(:,{'Mrr','Mtt','Mpp','Mrt','Mrp','Mtp'});
            mt{:,:}=mt{:,:}.* 10.^double(obj.allNDKs.ExponentForAllMomentValues);
            mt.Properties.VariableNames={'mrr', 'mtt', 'mff', 'mrt', 'mrf', 'mtf'};
            c.MomentTensor= mt;
            c.Dip=double(obj.allNDKs.Dip_NodalPlane1);
            c.DipDirection=double(obj.allNDKs.Strike_NodalPlane1)+ 90;
            c.Rake=double(obj.allNDKs.Rake_NodalPlane1);
        end
    end
    
    methods(Static)
        
        function NDKS = read(f)
            tx=fileread(f);
            NDKS = NDK(splitlines(strip(tx)));
        end
    end
end
