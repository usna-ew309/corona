function phand = drawCam_fov(fov,fr,Rotation_matrix,translation,frame_yn)
%function drawCam_MoCap_prettyf(fov, fr, Rotation_matrix, translation, frame_yn)
%
% fov is [2x1] field of view matrix fov(1) is angle of view wide in
% degrees, fov(2) is angle of view vertical in degrees
% 
% fr is range of field of view. 
% 
% Rotation_matrix is the camera transformation matrix in the world frame.
% cTw is [3 x 3]
% 
% frame_yn is 0 if you don't want the orthogonal frame on the camera and 1 if you
% want
%
% translation moves camera positions
% translation = [x_trans y_trans z_trans] 
%
%
% Example:
% drawCam([30,45], 100, eye(3), [1 0 1],1);
%



% Unit Vectors (specific to optitrack-Truss)
X = [1;0;0];
Y = [0;1;0];
Z = [0;0;1];


% camera cylinder radius
cylr=fr/40;
[camx camy camz] = cylinder(cylr);

% camera cylinder height
camz=camz*fr/30;


aovw = fov(1)*pi/180; % angle of view wide
aovv = fov(2)*pi/180;


fovrot = [1 0 0;0 cos(-pi/2) -sin(-pi/2);0 sin(-pi/2) cos(-pi/2)];


% camera base side
side_b=fr/15;

xbase = [ -side_b, side_b, side_b, -side_b];
ybase = [ -side_b, -side_b, side_b, side_b];
zbase = [ 0 , 0 , 0, 0];

% creating field of view 
my=tan(aovv/2)*fr; mx=tan(aovw/2)*fr;
xfov=[0 mx mx; 0 -mx mx; 0 -mx -mx;0 mx -mx]';
yfov=[0 my -my;0 my my; 0 my -my; 0 -my -my]';
zfov=[0 fr fr; 0 fr fr; 0 fr fr; 0 fr fr]';

ts = -pi/2;
fixRot = [cos(ts) -sin(ts) 0; sin(ts) cos(ts) 0;0 0 1];
rotate = [Rotation_matrix*fixRot*fovrot zeros(3,1);zeros(1,3) 1];

[camxg, camyg, camzg]=trpa2b(camx, camy, camz, rotate);
camxg = camxg+translation(1);
camyg = camyg+translation(2);
camzg = camzg+translation(3);

phand(1) = surf(camxg, camyg, camzg,'FaceColor', 'k', ...
            'FaceAlpha', .9, 'EdgeColor', 'none');
        hold on;




[xfovg yfovg zfovg]=trpa2b(xfov, yfov, zfov, rotate);


xfovg = xfovg+translation(1);
yfovg = yfovg+translation(2);
zfovg = zfovg+translation(3);

if (frame_yn)
phand(2) = patch(xfovg,yfovg,zfovg, [.5 .5 .5], 'EdgeColor', ...
            [.5 .5 .5], 'FaceAlpha',0.8);
end


% x_ax = Rotation_matrix*X;
% y_ax = Rotation_matrix*Y;
% z_ax = Rotation_matrix*Z;
% quiver3(translation(:,1),translation(:,2),translation(:,3),z_ax(1),z_ax(2),z_ax(3),.3,'r')
% quiver3(translation(:,1),translation(:,2),translation(:,3),x_ax(1),x_ax(2),x_ax(3),.3,'g')
% quiver3(translation(:,1),translation(:,2),translation(:,3),y_ax(1),y_ax(2),y_ax(3),.3,'b')
% plot3(translation(:,1),translation(:,2),translation(:,3),'*k','MarkerSize',10);
        
        
        
end