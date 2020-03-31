cntrlprms.despos = pi/4;
cntrlprms.Kp = 1.9016;
cntrlprms.Ki = 0.4992;
cntrlprms.Kd = 0.73;
dt = 0.05;
t = 0:dt:6;
[SSE,t,theta,omega,dc,eint] = sendCmdtoDcMotor('closed',cntrlprms,t);

figure(1); clf
subplot(4,1,1)
plot(t,theta*180/pi)
ylabel('Orientation (degrees)')
subplot(4,1,2)
plot(t,omega*180/pi)
ylabel('Angular Rate (degrees/sec)')
subplot(4,1,3)
plot(t(1:end-1),diff(omega)/dt*180/pi)
ylabel('Angular Acceleration (degrees/sec^2)')
subplot(4,1,4)
plot(t,dc)
ylabel('Duty Cycle')
xlabel('Time (s)')


svit = 1;
if svit==1
    saveas(gcf,'Testing_figure_CL.png','png')
end



cntrlprms.stepPWM = 0.4;
t = 0:dt:6;
[SSE,t,theta,omega,dc,eint] = sendCmdtoDcMotor('step',cntrlprms,t);

figure(2); clf
subplot(4,1,1)
plot(t,theta*180/pi)
ylabel('Orientation (deg)')
subplot(4,1,2)
plot(t,omega*180/pi)
ylabel('Rate (deg/sec)')
subplot(4,1,3)
plot(t(1:end-1),diff(omega)/dt*180/pi)
ylabel('Acceleration (deg/sec^2)')
subplot(4,1,4)
plot(t,dc)
ylabel('Duty Cycle')
xlabel('Time (s)')


if svit==1
    saveas(gcf,'Testing_figure_OL.png','png')
end