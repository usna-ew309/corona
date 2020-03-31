function MVfit = createBallisticMVfit(X,Y,Z)
% CREATEBALLISTICMVSTATS calculates multivariate statistics for a ballistic
% distribution at various distances.
%   MVfit = CREATEBALLISTICMVSTATS(X,Y,Z) specifies the horizontal (X),
%   vertical (Y), and depth (Z) information as cell arrays:
%       X{i} - n-element x-data for the ith distance
%       Y{i} - n-element y-data for the ith distance
%       Z{i} - scalar *OR* n-element z-data for the ith distance (this is
%              the fixed distance for the data set).
%
%   M. Kutzer, 31Mar2020, USNA

%% Set debug flag(s)
plotsON = true;

%% Check input(s)
narginchk(3,3);

if ~iscell(X)
    error('X-data must be a cell-array.');
end
if ~iscell(Y)
    error('Y-data must be a cell-array.');
end
if ~iscell(Z)
    error('Z-data must be a cell-array.');
end

n = numel(X);
if numel(Y) ~= n || numel(Z) ~= n
    error('X, Y, and Z data must contain the same number of cells.');
end
% TODO - finish checking inputs

%% Calculate statistics
for i = 1:n
    x = reshape(X{i},[],1);
    y = reshape(Y{i},[],1);
    
    muCELL{i}    = mean([x,y]);
    SigmaCELL{i} = cov([x,y]);
end

%% Reformat statistics for fit parameters
for i = 1:n
    [V,D] = eig(SigmaCELL{i});
    
    Sigma.Axis(i,:)  = sqrt(diag(D)).';
    Sigma.Angle(i,1) = atan2(V(2,1),V(1,1));
    mu(i,:) = muCELL{i};
    
    z(i,1) = Z{i}(1);
end

%% Fit to data
MVfit.Axis1 = polyfit(z,Sigma.Axis(:,1),1);
MVfit.Axis2 = polyfit(z,Sigma.Axis(:,2),1);
MVfit.Angle = polyfit(z,Sigma.Angle(:,1),1);
MVfit.MeanX = polyfit(z,Sigma.mu(:,1),1);
MVfit.MeanY = polyfit(z,Sigma.mu(:,2),1);

%% Plot result(s)
if plotsON
    zFIT = linspace(0,max(z),1000);
    propNames = fields(MVfit);
    ylbls = {'Sigma Axis 1','Sigma Axis 2','Sigma Angle','Mean X','Mean Y'};
    fig = figure('Name','Multivariate Ballistics');
    
    m = numel(ylbls);
    for i = 1:m
        axs(i) = subplot(4,1,i,'Parent',fig);
        xlabel(axs(i),'Distance (z)');
        ylabel(axs(i),ylbls{i});
        
        pFIT = polyval(MVfit.(propNames{i}),zFIT);
        fit(i) = plot(axs(i),zFIT,pFIT,'-b','LineWidth',1.5);
    end
    
    plt(1) = plot(axs(i),z,Sigma.Axis(:,1),'*m','MarkerSize',8);
    plt(2) = plot(axs(i),z,Sigma.Axis(:,2),'*m','MarkerSize',8);
    plt(3) = plot(axs(i),z,Sigma.Angle(:,1),'*m','MarkerSize',8);
    plt(4) = plot(axs(i),z,mu(:,1),'*m','MarkerSize',8);
    plt(5) = plot(axs(i),z,mu(:,2),'*m','MarkerSize',8);
end
