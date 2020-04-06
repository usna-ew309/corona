cntrlprms.despos = pi/4;
cntrlprms.Kp = .3;
cntrlprms.Ki = .1;
cntrlprms.Kd = .1;
dt = 0.05;
t = 0:dt:10;
length(t)
[SSE,set_time,t,theta,omega,dc,eint] = sendCmdtoDcMotor('closed',cntrlprms,t);
length(t)

figure(1); clf
subplot(4,1,1)
plot(t,theta*180/pi)
hold on
plot(set_time.time,theta(set_time.index)*180/pi,'*k')
plot(t,1.02*theta(end)*180/pi*ones(size(t)),'--r')
plot(t,0.98*theta(end)*180/pi*ones(size(t)),'--r')
ylabel('Orientation (degrees)')
subplot(4,1,2)
plot(t,omega*180/pi)
hold on
plot(t(1:end-1),diff(theta)/dt*180/pi,'--r')
legend('ODE45 result','numerical differencing of theta')
ylabel('Ang. Rate (deg./sec)')
subplot(4,1,3)
plot(t(1:end-1),diff(omega)/dt*180/pi)
ylabel('Ang. Acc. (deg./sec^2)')
subplot(4,1,4)
plot(t,dc)
ylabel('Duty Cycle')
xlabel('Time (s)')


svit = 0;
if svit==1
    saveas(gcf,'Testing_figure_CL.png','png')
end



% cntrlprms.stepPWM = 0.4;
% t = 0:dt:6;
% [SSE,t_settle,t,theta,omega,dc,eint] = sendCmdtoDcMotor('step',cntrlprms,t);
% 
% figure(2); clf
% subplot(4,1,1)
% plot(t,theta*180/pi)
% ylabel('Orientation (deg)')
% subplot(4,1,2)
% plot(t,omega*180/pi)
% ylabel('Rate (deg/sec)')
% subplot(4,1,3)
% plot(t(1:end-1),diff(omega)/dt*180/pi)
% ylabel('Acceleration (deg/sec^2)')
% subplot(4,1,4)
% plot(t,dc)
% ylabel('Duty Cycle')
% xlabel('Time (s)')


% if svit==1
%     saveas(gcf,'Testing_figure_OL.png','png')
% end