function EW309coronaPerforanceEval

global hFOV_global

%% Get hangles
kids = get(hFOV_global.getTargetImage.h_a2r,'Children');

h_a2aw = findobj(kids,'Type','hgtransform');
ptcSho = findobj(h_a2aw,'Type','patch');
ptcTar = findobj(kids,'Type','patch');

%% Create figure
fig = figure('Name','EW309corona Performance Summary','Units','Normalized',...
    'Position',[0,0,0.75,0.75]);
centerfig(fig);
axs = axes('Parent',fig);
title(axs,'EW309corona Performance Summary');
hold(axs,'on');
daspect(axs,[1 1 1]);
xlabel('x (mm)');
ylabel('y (mm)');

h_a = triad('Parent',axs,'Visible','off');
H_a2aw = get(h_a2aw,'Matrix');
h_aw2a = triad('Parent',h_a,'Matrix',H_a2aw,'Visible','off');

% Display target
ptc = copyobj(ptcTar,h_aw2a);
set(ptc,'EdgeColor','k');
% Display shots
sho = copyobj(ptcSho,h_a);
set(sho,'EdgeColor','k','FaceAlpha',0.5);
% Number shots
for i = 1:numel(sho)
    % Get vertices
    v = get(sho(i),'Vertices').';
    % Find centroid
    polyin = polyshape(v(1,:),v(2,:));
    [x,y] = centroid(polyin);
    % Add number 
    txt(i) = text(x,y,sprintf('%d',i),'Parent',h_a,'HorizontalAlignment','Center','VerticalAlignment','Middle');
end

axis(axs,'tight');