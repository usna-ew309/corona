% SCRIPT_SaveMVfit
% This function processes the MVfit information and saves a file containing
% the fit paramters.
%
%   M. Kutzer, 01Apr2020, USNA

%% Format the ballistics data
SCRIPT_FormatBallisticsData;

%% Calculate the fit
MVfit = createBallisticMVfit(X,Y,Z);

%% Save MVfit
fname = 'MVfit.mat';
save(fname, 'MVfit');

%% Compare fits
for i = 1:numel(Z)
    fig = figure('Name',sprintf('Distance %.2fcm',Z{i}));
    axs = axes('Parent',fig);
    daspect(axs,[1 1 1]);
    hold(axs,'on');
    xlabel(axs,'x (cm)');
    ylabel(axs,'y (cm)');
    title(axs,sprintf('Distance %.2fcm',Z{i}));
    
    plt(1) = plot(axs,X{i},Y{i},'ob');
    
    range = Z{i};
    nShots = numel(X{i});
    
    [x,y] = fireShots(range,10*nShots);
    plt(2) = plot(axs,x,y,'xg');
    
    [x,y] = getShotPattern(range,10*nShots);
    plt(3) = plot(axs,x,y,'+m');
end