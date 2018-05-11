classdef DataStore<handle
    % DATASTORE is an adapter from zmap to the MapSeis Datastore
    
    properties
        % gives the type determined by the decluster algorithmen categorical
        % (1:single event, 2: mainshock, 3:aftershock and 0: unclassified)
        EventType
        
        % sets the number of the cluster a event belongs to (is NaN for single event)
        ClusterNR
        
        % is a 3 element vector and sets which eventtypes are used in the datastore 
        % [singleToggle mainshockToggle aftershockToggle]
        TypeUsed
        
        ShowUnclassified = true 
        catalog % earthquake catalog
        
        % optional field and is used to store additional info of the decluster algorithmen
        DeclusterMetaData
        
        UserData = containers.Map % User-specific settings eg filter settings etc
         
        %filled with UserData names which contain data which is
		%available for each catalog entry (those events will be automatically
		%filtered in case filtered data is edited)
        NumberedUserData={};
    end
    
    methods
            
        
        function setDeclusterData(obj,EventType,ClusterNR,selected,ShowParts)
            %sets the declustering data
            %ShowParts can be empty, in this case it will be set to true for
            %all parts or will be kept if TypeUsed is already defined
            % SETDECLUSTERDATA(obj,EventType,ClusterNR,selected,ShowParts)
            % EventType : type of event: 
            
            % This file is part of MapSeis.
            
            % MapSeis is free software: you can redistribute it and/or modify
            % it under the terms of the GNU General Public License as published by
            % the Free Software Foundation version 3 of the License.
            
            % MapSeis is distributed in the hope that it will be useful,
            % but WITHOUT ANY WARRANTY; without even the implied warranty of
            % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            % GNU General Public License for more details.
            
            %You should have received a copy of the GNU General Public License
            % along with MapSeis.  If not, see <http://www.gnu.org/licenses/>.
            
            % Copyright 2010 David Eberhard
            
            
            if nargin<5
                ShowParts=[];
            end
            
            if isempty(obj.EventType)
                %create new arrays with unclasified data
                obj.EventType = categorical(zeros(obj.getRawRowCount,1),...
                    [0 1 2 3],...
                    {'unclassified','single event','mainshock','aftershock'});
                obj.ClusterNR=NaN(obj.getRawRowCount,1);
                
            end
            if isempty(selected)
                selected=true(size(obj.EventType));
            end
            
            obj.EventType(selected)=EventType;
            obj.ClusterNR(selected)=ClusterNR;
            
            if ~isempty(ShowParts)
                obj.TypeUsed=ShowParts;
                
            elseif isempty(obj.TypeUsed)
                obj.TypeUsed=true(3,1);
            end
            
            if isempty(obj.ShowUnclassified)
                obj.ShowUnclassified=true;
            end
            
            % updateObservers(obj);
        end

        function c = getRawRowCount(obj)
            c=obj.catalog.Count;
        end
    end
end