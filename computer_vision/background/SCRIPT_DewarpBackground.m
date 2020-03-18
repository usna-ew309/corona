%% SCRIPT_DewarpBackground
clear all
close all
clc

%% Define file info
pname = 'data';
roomIDs = {'Ri078','Ri080'};
directionIDs = {'SW','SE','NE','NW'};

L = 8.40e3; % mm
W = 8.18e3; % mm
H = 2.83e3; % mm
wallDimensions{1,1} = [L,H]; % Ri078, SW Wall
wallDimensions{1,2} = [W,H]; % Ri078, SE Wall
wallDimensions{1,3} = [L,H]; % Ri078, NE Wall
wallDimensions{1,4} = [W,H]; % Ri078, NW Wall

L = 7.60e3; % mm
W = 8.50e3; % mm
H = 2.71e3; % mm
wallDimensions{2,1} = [L,H]; % Ri080, SW Wall
wallDimensions{2,2} = [W,H]; % Ri080, SE Wall
wallDimensions{2,3} = [L,H]; % Ri080, NE Wall
wallDimensions{2,4} = [W,H]; % Ri080, NW Wall

%% Select initialize plot
filename = 'DigitizedWalls.mat';
if ~isfile(filename)
    fig = figure;
    axs = axes('Parent',fig);
    
    fname = sprintf('%s_%s_Wall.jpg',roomIDs{1},directionIDs{1});
    fname = fullfile(pname,fname);
    im = imread(fname);
    
    img = imshow(im,'Parent',axs);
    hold(axs,'on');
    set(axs,'Visible','on');
    set(fig,'Units','Normalized','Position',[0,0,1,1]);
    
    offset = 300;
    res = size(im);
    x = [offset,res(2)-offset];
    y = [offset,res(1)-offset];
    xx = [x(1),x(2),x(2),x(1)];
    yy = [y(1),y(1),y(2),y(2)];
    %plt = plot(axs,xx,yy,'om','LineWidth',1.5,'MarkerSize',10);%,'MarkerWidth',2);
    verts = [xx; yy].';
    
    % Allow polygon to be dragged
    [ptc,plt] = dragPolygon(axs,verts);
    
    for i = 1:numel(roomIDs)
        for j = 1:numel(directionIDs)
            % Read image
            fname = sprintf('%s_%s_Wall.JPG',roomIDs{i},directionIDs{j});
            im = imread(fullfile(pname,fname));
            
            % Update image
            set(img,'CData',im);
            drawnow;
            
            title('Press "q" to save points.');
            waitForKey(fig,'q');
            
            X_m{i,j} = get(ptc,'Vertices').';
            set(ptc,'Vertices',verts);
            for k = 1:numel(xx)
                set(plt(k),'XData',xx(k),'YData',yy(k));
            end
        end
    end
    delete(fig);
    
    save(filename,'X_m','roomIDs','directionIDs','wallDimensions');
else
    load(filename);
end

