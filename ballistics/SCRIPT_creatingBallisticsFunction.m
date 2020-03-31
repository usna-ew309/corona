clear all
clc

load('Ballistics_Process_stats.mat')


psx = polyfit(dist,Sx,1);
psy = polyfit(dist,Sy,1);
psx(2) = 0;
newdist = linspace(0,dist(end));


figure(1); clf
subplot(4,1,1)
plot(dist,mean_x,'*',newdist,px(1)*newdist+px(2))
axis([0 600 0 10])
ylabel('x-bias (cm)')
subplot(4,1,2)
plot(dist,mean_y,'*',newdist,py(1)*newdist+py(2))
hold on
plot(dist(3),mean_y(3),'or','Linewidth',2,'MarkerSize',10)
axis([0 600 -10 30])
ylabel('y-bias (cm)')
subplot(4,1,3)
plot(dist,Sx,'*',newdist,psx(1)*newdist+psx(2))
axis([0 600 0 10])
ylabel('x-std (cm)')
subplot(4,1,4)
plot(dist,Sy,'*',newdist,psy(1)*newdist+psy(2))
axis([0 600 0 10])
ylabel('y-std (cm)')
xlabel('Range (cm)')




%Import data from various spreadsheets that have four different ranges
pathname = 'C:\Users\devries\Documents\GitHub\corona\ballistics\data\';
filenames = {'173centimeters.xlsx','274centimeters.xlsx','323centimeters.xlsx','584centimeters.xlsx'};

%create vector of four distances in centimeter
dist = [1.73 2.74 3.23 5.84]*100;


for ii = 1:length(filenames)
    

%parse the numerical, text, and raw data 
[num,txt,raw] = xlsread([pathname filenames{ii}]);

%assign variable to data
data.x_pix = num(:,1);
data.y_pix = num(:,2);
data.x_cm = num(:,3);
data.y_cm = num(:,4);

n = length(data.x_cm); %number of data points

% generate artificial shots
[xPositions,yPositions] = fireShots(dist(ii),n);

% Plot results for raw shot data (uncorrect for bias error)
f1 = figure(2); 
hold on

subplot(2,2,ii)
p1 = plot(data.x_cm,data.y_cm,'o','MarkerFaceColor','b');
hold on
grid on
p1new = plot(xPositions,yPositions,'om','MarkerFaceColor','m');
title(filenames{ii});
xlabel('X (cm)');
ylabel('Y (cm)');

axis square;
axis equal
axis(40*[-1 1 -1 1])

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

f2 = figure(3);
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
