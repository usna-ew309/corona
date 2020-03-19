function [ptc,plt] = dragPolygon(axs,verts)
% DRAGPOLYGON allows a user to drag an n-point polygon specified using a
% series of Nx2, 2-dimensional vertices.
%   [ptc,plt] = DRAGPOLYGON(axs,verts) specifies the axis that will contain
%   the polygon (axs), and the vertices of the polygon. This function
%   returns a single patch handle (ptc), and an N-element array of plot
%   handles. 
%
%   References:
%       [1] F. Bouffard, "draggable.m," 
%       https://www.mathworks.com/matlabcentral/fileexchange/4179-draggable
%
%   M. Kutzer, 18Mar2020, USNA

global ptc 

addpath('draggable');

hold(axs,'on');
ptc = patch(axs,'Faces',1:size(verts,1),'Vertices',verts,'FaceColor','None','EdgeColor','m');%,'EdgeWidth',2);

xx = verts(:,1);
yy = verts(:,2);
for i = 1:numel(xx)
    plt(i) = plot(axs,xx(i),yy(i),'om','LineWidth',1.5,'MarkerSize',10,'Tag',sprintf('%d',i));
    
    draggable(plt(i),@motionfcn);
end

end

function motionfcn(h)

global ptc

%fprintf('I am running %s...',get(h,'Tag'));
i = str2double( get(h,'Tag') );
x = get(h,'XData');
y = get(h,'YData');

v = get(ptc,'Vertices');
v(i,:) = [x,y];
set(ptc,'Vertices',v);
drawnow
%fprintf('\n');

end