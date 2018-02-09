function [fCumMoment, vCumMoment, vMoment] = calc_moment(mCatalog)
% function [fCumMoment, vCumMoment, vMoment] = calc_moment(mCatalog);
% -------------------------------------------------------------------------
%
% Calculates the (cumulative) moment release in Nm of the catalog using
% either a vector of magnitudes or a ZMAP catalog format
% Reference : Kanamori, H., The energy release in great
%             earthquakes. JGR, 82, 2981-2987, 1977
%
% Incoming variables:
% mCatalog : either a catalog in ZMAP format or a vector of magnitudes
%
% Outgoing variables:
% fCumMoment : Cumulative moment release of eq catalog [Nm]
% vCumMoment : Vector of the cumulative moment release [Nm]
% vMoment    : Vector of single event moment release [Nm]
% J. Woessner, j.woessner@sed.ethz.ch
% updated: 09.11.05


if isa(mCatalog,'ZmapCatalog') && mCatalog.Count > 1
    % Sort the catalog according to time
    mCatalog.sort('Date');
    %[s,is] = sort(mCatalog.Date);
    %mCatalog = mCatalog(is(:,1),:);
    % Use magnitude column from ZMAP data catalog format
    vMagnitude = mCatalog.Magnitude;
else
    % Use one column magnitude vector
    vMagnitude = mCatalog;
end

% Cumulative moment release
vCumMoment = cumsum(10.^(1.5*vMagnitude + 9.05));
fCumMoment = vCumMoment(length(vCumMoment),1);

% Moment released per event
vMoment = 10.^(1.5*vMagnitude + 9.05);
