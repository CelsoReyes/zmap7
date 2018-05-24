classdef NDK
    %
    %
    % from : https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/allorder.ndk_explained
    properties
        % from line 1 of NDK format : Hypocenter line
        HypocenterReferenceCatalog
        ReferenceEventDateTime
        Latitude
        Longitude
        Depth
        ReportedMagnitudes
        GeographicalLocation
        %from line 2 of NDK format : CMT info (1)
        CMTEventName
        
        LongPeriodBodyWaves_NumStationsUsed
        LongPeriodBodyWaves_NumComponentsUsed
        LongPeriodBodyWaves_ShortestPeriodUsed
        IntermediatePeriodSurfaceWaves_NumStationsUsed
        IntermediatePeriodSurfaceWaves__NumComponentsUsed
        IntermediatePeriodSurfaceWaves_ShortestPeriodUsed
        LongPeriodMantleWaves_NumStationsUsed
        LongPeriodMantleWaves__NumComponentsUsed
        LongPeriodMantleWaves_ShortestPeriodUsed
        
        %"CMT: 0" - general moment tensor; 
        %"CMT: 1" - moment tensor with constraint of zero trace (standard); 
        %"CMT: 2" - double-couple source.
        TypeOfSourceInvertedFor
        MomentRateFunctionType
        MomentRateFunctionDuration
        
        % from line 3 of NDK format : CMT info (2)
        Centroid_Time % wrt reference time
        Centroid_TimeStderr
        Centroid_Lat
        Centroid_LatStderr
        Centroid_Lon
        Centroid_LonStderr
        Centroid_Depth
        Centroid_DepthStderr
        CentroidDepthType % one of FREE, FIX, BODY
        TimeStampPrefix
        TimeStamp
        
        % from line 4 of NDK format : CMT info (3)
        ExponentForAllMomentValues
        Mrr % r is up
        MrrStderr
        Mtt % t is south
        MttStderr
        Mpp % p is east
        MppStderr
        Mrt
        MrtStderr
        Mrp
        MrpStderr
        Mtp
        MtpStderr
        
        % from line 5 of NDK format : CMT info (4)
        VersionCode
        MTEigenvalue
        MTPlunge
        MTAzimuth
        ScalarMoment
        Strike
        Dip
        Rake
    end
    
    methods
        function obj = NDK(ndktext)
            if nargin>0 && ~isempty(ndktext)
                
                % get first line
                s=char(string(ndktext{1}));
                if startsWith(s,'    ')
                    s(1:4)='-';
                end
                add_a_minute=s(23)=='6';
                if add_a_minute
                    s(23)='0';
                end
                c=textscan(s,'%4s %{uuuu/MM/DD}D %{HH:mm:ss.s}D %6.2f %6.2f %5.1f %3.1f %3.1f %s');
            [obj.HypocenterReferenceCatalog,...
                datepart, timepart,...
                obj.Latitude,...
                obj.Longitude,...
                obj.Depth,...
                mag1,mag2,...
                obj.GeographicalLocation]=deal(c{:});
            obj.ReportedMagnitudes = [mag1, mag2];
            obj.HypocenterReferenceCatalog=string(obj.HypocenterReferenceCatalog);
            if add_a_minute
                timepart=timepart+minutes(1);
            end
            obj.ReferenceEventDateTime=datepart+timeofday(timepart);
            obj.GeographicalLocation=string(obj.GeographicalLocation);
            
            % get second line
            %{
                s = replace(ndktext{2},':',' ');
                s = strip(split(s));
                [obj.CMTEventName,...
                    ~,...
                obj.LongPeriodBodyWaves_NumStationsUsed,...
                obj.LongPeriodBodyWaves_NumComponentsUsed,...
                obj.LongPeriodBodyWaves_ShortestPeriodUsed,...
                ~,...
                obj.IntermediatePeriodSurfaceWaves_NumStationsUsed,...
                obj.IntermediatePeriodSurfaceWaves__NumComponentsUsed,...
                obj.IntermediatePeriodSurfaceWaves_ShortestPeriodUsed,...
                ~,...
                obj.LongPeriodMantleWaves_NumStationsUsed,...
                obj.LongPeriodMantleWaves__NumComponentsUsed,...
                obj.LongPeriodMantleWaves_ShortestPeriodUsed,...
                ~,...
                obj.TypeOfSourceInvertedFor,...
                obj.MomentRateFunctionType,...
                obj.MomentRateFunctionDuration] = deal(s{:});
            %}
        end
        end
                
            
    end
    
    methods(Static)
        
        function NDKS = read(f)
            tx=fileread(f);
            s=splitlines(strip(tx));
            %s(2:5:end)=replace(s(2:5:end),':',' ');
            NDKS=repmat(NDK,numel(s)/5,1);
            n=0;
            z=1;
            disp('entering loop');
            while z+5 < numel(s)
                n=n+1;
                z=z+5;
                %try
                NDKS(n)=NDK(s(z:z+4));
                %catch ME
                 %   warning(ME.message);
                %    break
                %end
            end
        end
    end
end
