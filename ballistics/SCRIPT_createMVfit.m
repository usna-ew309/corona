% SCRIPT_createMVfit
% This function processes the MVfit information and saves a file containing
% the fit paramters.
%
%   M. Kutzer, 01Apr2020, USNA

%% Format the ballistics data
SCRIPT_FormatBallisticsData;

%% Save media flag 
saveMedia = false;

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

    
    range = Z{i};
    nShots = numel(X{i});
    
    [x,y] = fireShots(range,100*nShots);
    plt(1) = plot(axs,x,y,'xg');
    
    [x,y] = getShotPattern(range,100*nShots);
    plt(2) = plot(axs,x,y,'+m');

    plt(3) = plot(axs,X{i},Y{i},'ob','MarkerFaceColor','b','MarkerSize',8);
    legend(axs,{'Decoupled Fit','Coupled Fit','Collected Data'},'Location','northeastoutside');
    
    set(fig,'Units','Normalized','Position',[0,0,0.75,0.75]);
    centerfig(fig);
    drawnow
    if saveMedia
        fname = sprintf('%dcentimeters.png',range);
        saveas(fig,fname,'png');
    end
end
