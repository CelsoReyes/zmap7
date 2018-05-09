classdef DataStore<handle
    % DATASTORE is an adapter from zmap to the MapSeis Datastore
    
    properties
        EventType
        ClusterNR
        TypeUsed
        ShowUnclassified
        catalog
        DeclusterMetaData
        NumberedUserData
    end
    
    methods
            
        
        function setDeclusterData(obj,EventType,ClusterNR,selected,ShowParts)
            %sets the declustering data
            %ShowParts can be empty, in this case it will be set to true for
            %all parts or will be kept if TypeUsed is already defined
            
            
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
                obj.EventType=zeros(obj.getRawRowCount,1);
                obj.ClusterNR=NaN(obj.getRawRowCount,1);
                
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