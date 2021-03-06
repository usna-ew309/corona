% Process_Ballistics_Data imports ballistics data from four excel spreadsheets
% and computes the ballistic statistics for each range.  

% The statistics include: 
%    (1) mean_x,mean_y,Sx,Sy: sample mean and sample standard deviation in x and y dimension
%    (2) S_P, S_B: precision and bias error 
%    (3) x_corr, y_corr, k, CEP_50: bias-corrected impact points, scale
%    factor, and 50% CEP
%    (4) CEP_upper, CEP_lower: 95% confidence interals on the 50% CEP
%    (5) px, py, pSp: the poly fit data for the bias and precision errors


% The plots include
% (1) the raw (bias-uncorrected) impact points for each range
% (2) the bias-correct impact points, CEP and 95% confidence intervals on the CEP
% (3) The polyfits for bias and precision error



% T. Severson, USNA, EW309, AY2020
clear all;
close all;
clc;

%Import data from various spreadsheets that have four different ranges

for ii = 1:4
    
[filename,pathname] = uigetfile('*.xlsx','Select appropriate data file');

%parse the numerical, text, and raw data 
[num,txt,raw] = xlsread([pathname filename]);

%assign variable to data
data.x_pix = num(:,1);
data.y_pix = num(:,2);
data.x_cm = num(:,3);
data.y_cm = num(:,4);

n = length(data.x_cm); %number of data points


% Plot results for raw shot data (uncorrect for bias error)
f1 = figure(1); 
hold on

subplot(2,2,ii)
p1 = plot(data.x_cm,data.y_cm,'o');
title(filename);
xlabel('X (cm)');
ylabel('Y (cm)');

curr_axes = gca;
x_lim = get(curr_axes,'XLim');
y_lim = get(curr_axes,'YLim');
max_pt = max(x_lim(2),y_lim(2));
axis([-max_pt max_pt -max_pt max_pt])
axis square;

%compute the sample mean (bias error) in x and y (assuming independent).

mean_x(ii) = mean(data.x_cm);
mean_y(ii) = mean(data.y_cm);

%compute the Sample Standard Deviation
Sx(ii) = std(data.x_cm); 
Sy(ii) = std(data.y_cm);

%compute the total precision and bias error and 50% CEP
S_P(ii) = 0.5*(Sx(ii)+Sy(ii));
S_B(ii) = sqrt(mean_x(ii)^2+mean_y(ii)^2);

%correct for bias error and calculate the 50% CEP
x_corr = data.x_cm - mean_x(ii);
y_corr = data.y_cm - mean_y(ii);

k = (-2*log(1-0.5))^0.5;
CEP_50(ii) = k*S_P(ii);


%Compute the 95% confiednce on CEP
Sx_low   = Sx(ii)*sqrt((n-1)/chi2inv((1+0.95)/2,n-1));
Sx_high  = Sx(ii)*sqrt((n-1)/chi2inv((1-0.95)/2,n-1));
Sy_low   = Sy(ii)*sqrt((n-1)/chi2inv((1+0.95)/2,n-1));
Sy_high  = Sy(ii)*sqrt((n-1)/chi2inv((1-0.95)/2,n-1));

errlow  = sqrt(k/2*(Sx_low-Sx(ii))^2+(Sy_low-Sy(ii))^2);
errhigh = sqrt(k/2*(Sx_high-Sx(ii))^2+(Sy_high-Sy(ii))^2);

CEP_lower  = CEP_50(ii)-errlow;
CEP_upper  = CEP_50(ii)+errhigh;

f2 = figure(2);
hold on
subplot(2,2,ii)
p2 = plot(x_corr,y_corr,'o','markerfacecolor','g');
grid on; 

% Label axes
xlabel('(cm)');
ylabel('(cm)');
%title_txt = ['CEP = ',num2str(cep,'%.3f'),'(m)','range =',range];
title_txt = ['CEP = ',num2str(CEP_50(ii),'%.3f'),'(cm)'];
h = title(title_txt);

CEP_cir = viscircles([0 0],CEP_50(ii),'EdgeColor','b');

% Draw 95% confidence boundaries
CEP_upp = viscircles([0 0],CEP_upper,'EdgeColor','g');
CEP_low = viscircles([0 0],CEP_lower,'EdgeColor','g');

% Make axes limits same
curr_axes = gca;
x_lim = get(curr_axes,'XLim');
y_lim = get(curr_axes,'YLim');
min_pt = min(x_lim(1),y_lim(1));
axis([min_pt -min_pt min_pt -min_pt]);
axis square;

% Legend
legend('POI');


end

%Fit bias (both x and y) and precision data to a curve

%create vector of four distances in centimeter
dist = [1.73 2.74 3.23 5.84]*100;

%fit a nth order polynomial to the data. Be sure to have all the units the
%same (meter and meter or centimeter and centimeters)

n_order = 1; %choose either 1st or 2nd order

px = polyfit(dist,mean_x,n_order);
py = polyfit(dist,mean_y,n_order);


pSp = polyfit(dist,S_P,1);

%create the best fit line (or curve) based on polynomial fit
newdist = linspace(0,dist(end));

new_x = px(1)*newdist+px(2);
new_y = py(1)*newdist+py(2);
new_SP = pSp(1)*newdist+pSp(2);

%plot the bias error vs the best fit lines
figure(3)
hold on
subplot(3,1,1);
plot(dist,mean_x,'*',newdist,new_x)
xlabel('range (cm)','interpreter','latex')
ylabel('x bias (cm)','interpreter','latex')

subplot(3,1,2)
plot(dist,mean_y,'*',newdist,new_y)
xlabel('range (cm)','interpreter','latex');
ylabel('y bias (cm)','interpreter','latex');

subplot(3,1,3)
plot(dist,S_P,'*',newdist,new_SP)
xlabel('range (cm)','interpreter','latex');
ylabel('Precision error (cm)','interpreter','latex');


save('Ballistics_Process_stats','mean_x','px','mean_y','py','Sx','Sy','dist')