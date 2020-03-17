%% SCRIPT_BalisticsAnalysis
% Remember, students should first convert their units to SI. This exercise
% does not perform the conversion, and leaves units in feet and inches.
%
% M. Kutzer, 31Jan2017, USNA

%% CCC
clear all
close all
clc

% Define save figures flag
saveFigures = false;

% Load ballistics data
[Distance,Horizontal_Error_POA,Vertical_Error,Vertical_Error_POA] = ...
    importfile('Midn_Reis_shot_data_MATLAB_Formatted');

%% Parse data
distances = unique(Distance);

for i = 1:numel(distances)
    distance = distances(i);
    idx = find(Distance == distance);
    x{i,1} = Horizontal_Error_POA(idx,:);
    y{i,1} = Vertical_Error_POA(idx,:);
end

%% Calculate simplified statistics for each distance
for i = 1:numel(distances)
    % Calculate x and y mean
    x_bar(i,1) = mean(x{i,1});
    y_bar(i,1) = mean(y{i,1});
    
    % Calculate individual variances (assuming decoupled data)
    s_x(i,1) = var(x{i,1});
    s_y(i,1) = var(y{i,1});
    
    % Calculate decoupled standard deviation
    std_x(i,1) = sqrt( s_x(i,1) );
    std_y(i,1) = sqrt( s_y(i,1) );
    
    % Calculate the decoupled variances of the mean
    s_x_bar(i,1) = s_x(i,1)/sqrt(numel(x{i,1}));
    s_y_bar(i,1) = s_y(i,1)/sqrt(numel(y{i,1}));
    
    % Calculate decoupled standard deviation of the mean
    std_x_bar(i,1) = sqrt(s_x_bar(i,1));
    std_y_bar(i,1) = sqrt(s_y_bar(i,1));
    
    % Calculate covariance (this will acount for coupled data)
    S{i} = cov([x{i}, y{i}]);
end

%% Plot results
for i = 1:numel(distances)
    if saveFigures
        fig(i) = figure('Name',sprintf('Firing Data for Distance = %.2f (ft)',distances(i)));
    else
        fig(i) = figure('Name',sprintf('Firing Data for Distance = %.2f (ft)',distances(i)),'Units','Normalized','Position',[0,0,1,1]);
    end
    axs(i) = axes('Parent',fig(i));
    daspect(axs(i),[1 1 1]);
    hold(axs(i),'on');
    title(sprintf('Firing Data for Distance = %.2f (ft)',distances(i)));
    xlabel(axs(i),'x (inches)');
    ylabel(axs(i),'y (inches)');
    
    % Plot POA
    plot(0,0,'xg');
    text(0,0,'POA','Color','g');
    
    % Plot shots
    plot(x{i},y{i},'xk');
    
    % Plot Mean
    plot(x_bar(i),y_bar(i),'og');
    
    % Plot COE
    p = 0.95; % Confidence interval
    k = sqrt(-2*log(1-p));
    Sp(i,1) = (1/2) * ( std_x(i,1) + std_y(i,1) );
    cep(i,1) = k * Sp(i,1);
    % Plot COE circle
    theta = linspace(0,2*pi,100);
    plot(cep(i,1)*cos(theta) + x_bar(i), cep(i,1)*sin(theta) + y_bar(i),'b');
    
    % Plot COE Confidence
    n = numel(x{i});
    s_x_low(i,1)  = s_x(i) * sqrt( (n-1) / (chi2inv((1+p)/2, n-1)) );
    s_x_high(i,1) = s_y(i) * sqrt( (n-1) / (chi2inv((1-p)/2, n-1)) );
    s_y_low(i,1)  = s_x(i) * sqrt( (n-1) / (chi2inv((1+p)/2, n-1)) );
    s_y_high(i,1) = s_y(i) * sqrt( (n-1) / (chi2inv((1-p)/2, n-1)) );
    err_low(i,1)  = sqrt( (k/2) * (s_x_low(i)  - s_x(i))^2 + (s_y_low(i)  - s_y(i))^2 );
    err_high(i,1) = sqrt( (k/2) * (s_x_high(i) - s_x(i))^2 + (s_y_high(i) - s_y(i))^2 );
    
    cep_low(i,1) = cep(i) - err_low(i);     % low end of "low" error
    cep_low(i,2) = cep(i) - err_high(i);    % high end of "low" error
    cep_high(i,1) = cep(i) + err_low(i);    % low end of "high" error
    cep_high(i,2) = cep(i) + err_high(i);   % high end of "high" error
    
    theta = linspace(0,2*pi,100);
    for j = 1:2
        if cep_low(i,j) > 0
            % Positive CEP
            plot(cep_low(i,j) *cos(theta) + x_bar(i), cep_low(i,j) *sin(theta) + y_bar(i),'r');
        else
            % Negative CEP (avoid incorretly showing results)
            plot(0 *cos(theta) + x_bar(i), 0 *sin(theta) + y_bar(i),'r');
        end
        plot(cep_high(i,j)*cos(theta) + x_bar(i), cep_high(i,j)*sin(theta) + y_bar(i),'g');
    end
    
    % Plot rotated elipse
    z_star = 1.96; % associated with 95% confidence interval
    [V,D] = eig(S{i});
    std_S(i,:) = sqrt(diag(D))';
    alpha(i,1) = atan2(V(2,1),V(1,1));
    xy_rot = Rz(alpha(i,1),2)*[z_star*std_S(i,1)*cos(theta); z_star*std_S(i,2)*sin(theta); ones(size(theta))];
    plot(xy_rot(1,:) +  x_bar(i), xy_rot(2,:) + y_bar(i),'m');
    
    % Save axes dimensions
    x_lims(i,:) = xlim;
    y_lims(i,:) = ylim;
    
    if ~saveFigures
        legend('Point of Aim','Shot Impact','Mean Impact',...
            'Circular error probable (95%)',...
            'CEP 95% Confidence (low)','CEP 95% Confidence (high)',...
            'CEP 95% Confidence (low)','CEP 95% Confidence (high)',...
            '95% Confidence Interval');
    end
end

% Create uniform axes dimensions
for i = 1:numel(distances)
    xlims = [min(x_lims(:,1)),max(x_lims(:,2))];
    ylims = [min(y_lims(:,1)),max(y_lims(:,2))];
    set(axs(i),'xlim',xlims,'ylim',ylims);
    
    % Save Figures
    if saveFigures
        drawnow;
        saveas(fig(i),sprintf('CEP_Comparison_%.2f.png',distances(i)));
    end
end

%% Create polynomials for 3D estimates
% The following sections fit polynomials to various terms that will be
% useful in creating a firing decision function.

%% Create 3D estimate of mean
figure('Name','Mean Position vs. Distance');
axes('Parent',gcf,'NextPlot','add');
title('Mean Position vs. Distance');
xlabel('Distance (ft)');
ylabel('Mean offset from POA (in)');
plot([0; distances],[0; x_bar],'*r');
plot([0; distances],[0; y_bar],'*g');

% Fit polynomial
p_x_bar = polyfit([0; distances],[0; x_bar], 2);
p_y_bar = polyfit([0; distances],[0; y_bar], 2);

d = linspace(0,max(distances),100);
plot(d,polyval(p_x_bar,d),'--r');
plot(d,polyval(p_y_bar,d),'--g');

% Save Figure
if saveFigures
    drawnow;
    saveas(gcf,sprintf('%s.png','Mean Position vs. Distance'));
end

%% Analyze horizontal mean using an angular offset
figure('Name','Targeting Angle vs. Distance');
axes('Parent',gcf,'NextPlot','add');
title('Targeting Angle vs. Distance');
xlabel('Distance (ft)');
ylabel('Targeting Angle (radians)');

distances_in = distances * 12; % Convert to inches
psi = atan2(x_bar,distances_in);

plot(distances,psi,'*k');

% Fit polynomial
p_psi = polyfit(distances,psi, 1);

d = linspace(0,max(distances),100);
plot(d,polyval(p_psi,d),'--k');

% Save Figure
if saveFigures
    drawnow;
    saveas(gcf,sprintf('%s.png','Targeting Angle vs. Distance'));
end

%% CEP
figure('Name','CEP vs. Distance');
axes('Parent',gcf,'NextPlot','add');
title('CEP vs. Distance');
xlabel('Distance (ft)');
ylabel('CEP (in)');
plot(distances,cep,'*k');

p_cep = polyfit([0; distances],[0; cep], 2);
d = linspace(0,max(distances),100);
plot(d,polyval(p_cep,d),'--k');

% Save Figure
if saveFigures
    drawnow;
    saveas(gcf,sprintf('%s.png','CEP vs. Distance'));
end

%% Covariance
figure('Name','Covariance Eigenvalues vs. Distance');
axes('Parent',gcf,'NextPlot','add');
title('Covariance eigenvalues vs. Distance');
xlabel('Distance (ft)');
ylabel('Covariance Eigenvalues (in)');
plot([0; distances],[0; std_S(:,1)],'*r');
plot([0; distances],[0; std_S(:,2)],'*g');

% Fit polynomial
p_sx = polyfit([0; distances],[0; std_S(:,1)], 2);
p_sy = polyfit([0; distances],[0; std_S(:,2)], 2);

d = linspace(0,max(distances),100);
plot(d,polyval(p_sx,d),'--r');
plot(d,polyval(p_sy,d),'--g');

% Save Figure
if saveFigures
    drawnow;
    saveas(gcf,sprintf('%s.png','Covariance Eigenvalues vs. Distance'));
end

%% Ellipse orientation
figure('Name','Covariance Orientation vs. Distance');
axes('Parent',gcf,'NextPlot','add');
title('Covariance orientation vs. Distance');
xlabel('Distance (ft)');
ylabel('Covariance orientation (radians)');
alpha = wrapTo2Pi(alpha);
plot([0; distances],[0; alpha],'*k');

% Fit polynomial
p_alpha = polyfit([0; distances],[0; alpha], 2);

d = linspace(0,max(distances),100);
plot(d,polyval(p_alpha,d),'--k');

% Save Figure
if saveFigures
    drawnow;
    saveas(gcf,sprintf('%s.png','Covariance Orientation vs. Distance'));
end

%% Create super-cool 3D plot
fig3D = figure('Name','Super-cool 3D plots!');
axs3D = axes('Parent',fig3D);
hold(axs3D,'on')
xlabel('Shot x-confidence (in)');
ylabel('Shot y-confidence (in)');
zlabel('Target distance (ft)');
view(3);

d = linspace(0,max(distances),30);
for i = 1:numel(d)
    % Evaluate polynomials
    xx_bar = polyval(p_x_bar,d(i));
    yy_bar = polyval(p_y_bar,d(i));
    ppsi = polyval(p_psi,d(i));
    xxx_bar = (d(i) * 12) * tan(ppsi);
    
    ccep = polyval(p_cep,d(i));
    aalpha = polyval(p_alpha,d(i));
    ss_x = polyval(p_sx,d(i));
    ss_y = polyval(p_sy,d(i));
    
    % Plot results
    % Plot POA
    plot3(0,0,0,'xg');
    
    % Plot Mean (polynomial estimate)
    plot3(xx_bar,yy_bar,d(i),'og');
    % Plot Mean (angle estimate)
    plot3(xxx_bar,yy_bar,d(i),'xr');
    
    % Plot COE circle
    theta = linspace(0,2*pi,100);
    plot3(ccep*cos(theta) + xx_bar, ccep*sin(theta) + yy_bar,...
        repmat(d(i),1,numel(theta)),'b');
    
    % Plot rotated elipse
    z_star = 1.96; % associated with 95% confidence interval
    xy_rot = Rz(aalpha,2)*[z_star*ss_x*cos(theta); z_star*ss_y*sin(theta); ones(size(theta))];
    plot3(xy_rot(1,:) +  xx_bar, xy_rot(2,:) + yy_bar,...
        repmat(d(i),1,numel(theta)),'m');
end

% Save Figure
if saveFigures
    drawnow;
    saveas(fig3D,sprintf('%s.png','Super cool 3D plots'));
end