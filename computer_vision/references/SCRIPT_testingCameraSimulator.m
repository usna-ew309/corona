

% Create a target
posx = 60; % cm position in x-y plane
posy = 0; % cm position in x-y plane
ang = atan2(posy,posx);
posz = 30; % height of middle of target
circ = 10*exp(1i*linspace(0,2*pi,100)); % points for circle of radius 10 cm
tmpzpts = posz+imag(circ);
tmpxpts = posx + ones(size(circ));
tmpypts = real(circ);

pts = [cos(ang) sin(ang) 0; -sin(ang) cos(ang) 0; 0 0 1]*[tmpxpts;tmpypts;tmpzpts];



camp = [0 0 posz];
camang = pi/8;
rotMat = [cos(camang) -sin(camang) 0; sin(camang) cos(camang) 0; 0 0 1];
camdir = rotMat*[1;0;0]; % vector pointing direction of camera


% plot target in 3D world
fig = figure(1); clf
ax = axes('Parent',fig);
hold on
fi = fill3(ax,pts(1,:),pts(2,:), pts(3,:),'r');
sc = 10; % scale factor on arrow length
phand = drawCam_fov([45 45],100,rotMat,camp,1);
grid on
axis equal
axis(90*[-1 1 -1 1 0 1.5])
view(3)
title('Visualization of Inertial Frame')
xlabel('x (cm)')
ylabel('y (cm)')
zlabel('z (cm)')




% fig2 = figure(2); clf
% ax2 = axes('Parent',fig2);
% fi2 = fill3(ax2,pts(1,:),pts(2,:), pts(3,:),'r');
% ax2.CameraPosition = [0 0 posz]
% ax2.CameraViewAngle = 45
% camup([0 0 1])
% camtarget(sqrt(posx^2+posy^2)*camdir)
% axis equal
% xlim([0 65])
% ylim([-30 30])
% title('Visualization from Camera Frame')
% ylabel('x_{cam} (cm)')
% zlabel('y_{cam} (cm)')

