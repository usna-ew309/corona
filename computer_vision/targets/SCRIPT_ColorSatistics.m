%% SCRIPT_ColorSatistics
clear all
close all
clc

%% Define color file names
pname = 'data';
fnames{1} = {'bright_yellow01'};
fnames{2} = {'dark_orange01','dark_orange02'};
fnames{3} = {'light_orange01','light_orange02','light_orange03'};

%% Load colors and calculate statistics
for i = 1:numel(fnames)
    fieldname = fnames{i}{1}(1:end-2);
    r = [];
    g = [];
    b = [];
    for j = 1:numel(fnames{i})
        fname = fullfile(pname,[fnames{i}{j},'.png']);
        im = imread(fname);
        
        r = [r; reshape(im(:,:,1),[],1)];
        g = [g; reshape(im(:,:,2),[],1)];
        b = [b; reshape(im(:,:,3),[],1)];
    end
    % Calculate statistics
    colorStats.(fieldname).mean = mean( double([r,g,b]) );
    colorStats.(fieldname).cov  =  cov( double([r,g,b]) );
end

save('ColorStats.mat','colorStats');