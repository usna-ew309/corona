function [ptc,plt] = dragPolygon(axs,verts)

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