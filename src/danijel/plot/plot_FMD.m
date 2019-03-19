function [fBValue, fAValue, fStdDev, fMc, fMeanMag] = plot_FMD(mCatalog, varargin)
        % Creates and plots a frequency magnitude distribution including the b-value
    %  [fBValue, fAValue, fStdDev, fMc, fMeanMag] = PLOT_FMD(mCatalog,showCumulative, hAxes, sSymbol, sColor, bPlotB, nCalculateMC, binWidth)
    % -------------------------------------------------------------------------------------------

    %
    % PLOT_FMD(mCatalog) opens a figure and plots the frequency magnitude distribution
    %   with standard parameters
    %
    % Input parameters:
    %   mCatalog        Earthquake catalog
    %
    % Named Input Parameters:  use as PLOT_FMD(... , Name, value)
    %   ShowCumulative  Plot cumulative frequency magnitude distribution (true) or non-cumulative (false)
    %   Axes           Handle of axes to plot the frequency magnitude distribution
    %   Symbol         Type of symbol for plotting (refer to Matlab 'plot')
    %   Color          Color of plot (refer to Matlab 'plot')
    %   ShowBval          Also plot the b-value line with markers
    %   CalcMethod    Method to determine the magnitude of completeness
    %                   1: Maximum curvature
    %                   2: Fixed Mc = minimum magnitude (Mmin)
    %                   3: Mc90 (90% probability)
    %                   4: Mc95 (95% probability)
    %                   5: Best combination (Mc95 - Mc90 - maximum curvature)
    %   BinWidth        Magnitude binning of the catalog (default 0.1)
    %
    % Output parameters:
    %   fBValue         Calculated b-value
    %   fAValue         Calculateda-value
    %   fStdDev         Standard deviation of b-value
    %   fMc             Magnitude of completeness
    %   fMeanMag        Determined mean magnitude
    %
    % Danijel Schorlemmer
    % June 16, 2003
    
    report_this_filefun();
    
    p = inputParser();
    p.addRequired('mCatalog');
    p.addParameter('ShowCumulative', true);
    p.addParameter('Axes',          []);
    P.addParameter('Symbol',        's');
    p.addParameter('Color',         'k');
    p.addParameter('ShowBval',      true)
    p.addParameter('CalcMethod',    2);
    p.addParameter('BinWidth',      0.1);
    p.addParameter('MarkerSize',    12);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    
    if isempty(p.Results.Axes)
        figure;
        hAxes=newplot;
    else
        hAxes = p.Results.Axes;
    end
    
    binWidth = p.Results.BinWidth;
    sColor = p.Results.Color;
    % Activate given axes
    axes(hAxes);
    
    
    
    % Create the frequency magnitude distribution vector
    [nEvsCum, nEvsNonCum, magX] = calc_FMD(mCatalog.Magnitude);

    
    % Plot the frequency magnitude distribution
    if p.Results.showCumulative
        hPlot = semilogy(magX, nEvsCum);
    else
        hPlot = semilogy(magX, nEvsNonCum);
    end
    
    hPlot.Symbol = p.Results.Symbol;
    hPlot.Color = p.Results.Color;
    hPlot.MarkerSize = p.Results.MarkerSize;
    
    
    if p.Results.ShowBval
        % Add further plots to the axes
        hAxes.NextPlot = 'add';
        
        % Calculate magnitude of completeness
        fMc = calc_Mc(mCatalog, p.Results.CalcMethod, binWidth);
        
        % Determine the positions of 'x'-markers
        nIndexLo = find((magX < fMc + 0.05) & (magX > fMc - 0.05));
        
        % Plot the 'x'-marker
        hPlot = semilogy(magX(nIndexLo), nEvsCum(nIndexLo));
        hPlot.Marker = 'x';
        hPlot.Color = sColor;
        hPlot.LineWidth = 2.5;
        hPlot.MarkerSize = 12;
        
        hPlot = semilogy(magX(1), nEvsCum(1));
        hPlot.Marker = 'x';
        hPlot.Color = sColor;
        hPlot.LineWidth = 2.5;
        hPlot.MarkerSize = 12;
        
        % Calculate the b-value etc. for M > Mc
        vSel = mCatalog.Magnitude >= fMc-(binWidth/2);
        fMeanMag = mean(mCatalog.Magnitude(vSel));
        [ fBValue, fStdDev, fAValue] =  calc_bmemag(mCatalog.Magnitude(vSel), binWidth);
        
        % Plot the line representing the b-value
        vPoly = [-1*fBValue fAValue];
        
        fMagHi = magX(1);
        vMagnitudes = magX(fMc - 0.0001 <= magX & magX <= fMagHi);
        
        fBFunc = 10.^(polyval(vPoly, vMagnitudes));
        hPlot = semilogy(vMagnitudes, fBFunc, sColor);
        hPlot.LineWidth = 2.0;
    end
end