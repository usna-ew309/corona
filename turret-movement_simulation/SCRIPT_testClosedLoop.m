cntrlprms.despos = pi/4;
cntrlprms.Kp = 1.9016;
cntrlprms.Ki = 0.4992;
cntrlprms.Kd = 0.73;
t = 0:.05:6;
[SSE,t,theta,omega,eint] = sendCmdtoDcMotor('closed',cntrlprms,t);

figure(1); clf
subplot(3,1,1)
plot(t,theta*180/pi)
ylabel('Orientation (degrees)')
subplot(3,1,2)
plot(t,omega*180/pi)
ylabel('Angular Rate (degrees/sec)')
subplot(3,1,3)
plot(t(1:end-1),diff(omega)/.05*180/pi)
ylabel('Angular Acceleration (degrees/sec^2')
xlabel('Time (s)')

svit = 1;
if svit==1
    saveas(gcf,'Testing_figure.png','png')
end