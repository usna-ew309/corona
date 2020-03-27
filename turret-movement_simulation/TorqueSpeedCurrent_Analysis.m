% Data from TSD tests of motor at 24 volt input
speed24 = [398;300;186;55]*2*pi/60; % rad/s
torque24 = [50;108;168;220]*0.0070615518333333; % Nm
current24 = [1;2;3;4]; % amps

% plot torque speed curve, fit 1st order model, plot 12V curve from model
figure(1); clf
plot(speed24,torque24,'*')
p1 = polyfit(speed24,torque24,1); % fit first order model to data
hold on
plot(0:1:55,p1(1)*(0:1:55)+p1(2))
xlabel('speed (rad/s)')
ylabel('torque (Nm)')

% model parameters
alp = p1(1);
bet = p1(2)/24;

hold on
plot(0:1:33,alp*(0:1:33)+bet*12); % extrapolate to 12 V input
axis([0 60 0 1.8])
legend('24 Volt experimental data','24 volt model','12 volt model')

% plot current speed curve, fit first order model, plot 12v curve from
% model
figure(2); clf
plot(speed24,current24,'*')
p2 = polyfit(speed24,current24,1)
hold on
plot(0:1:55,p2(1)*(0:1:55)+p2(2))
xlabel('speed (rad/s)')
ylabel('current (amps)')

% model fit parameters
alp2 = p2(1);
bet2 = p2(2)/24;

hold on
plot(0:1:33,alp2*(0:1:33)+bet2*12); % extrapolate 12 V model
axis([0 60 0 5])
legend('24 Volt experimental data','24 volt model','12 volt model')

maxTorque12 = bet*12
maxCurrent12 = bet2*12
