function create3Dfov(varargin)
%CREATE3DFOV generates "Camera FOV, Ri078.fig" and "Camera FOV, Ri080.fig"
%   CREATE3DFOV saves the designated figures as files
%
%   CREATE3DFOV(saveFile) allows the user to specify whether or not to
%   save the *.fig files.
%       saveFile = {[true],false} where true results in saved files.
%
% Each figure contains the following hierarchy (discounting "triad.m" 
% lines) where tabs illustrate parent/child relationships:
%   Figure -------------------------- Tag: Figure, FOV Ri0**             
%       Axes ------------------------ Tag: Axes, FOV Ri0**
%           HgTransform ------------- Tag: Room Center Frame
%               HgTransform --------- Tag: West Corner Frame
%                   Light ----------- Tag: Light 1
%                   ...
%                   Light ----------- Tag: Light 8
%                   HgTransform ----- Tag: SW Wall Base Frame
%                       HgTransform - Tag: SW Wall Dewarp Frame
%                           Image --- Tag: SW Wall Image
%                   HgTransform ----- Tag: SE Wall Base Frame
%                       HgTransform - Tag: SE Wall Dewarp Frame
%                           Image --- Tag: SE Wall Image
%                   HgTransform ----- Tag: NE Wall Base Frame
%                       HgTransform - Tag: NE Wall Dewarp Frame
%                           Image --- Tag: NE Wall Image
%                   HgTransform ----- Tag: NW Wall Base Frame
%                       HgTransform - Tag: NW Wall Dewarp Frame
%                           Image --- Tag: NW Wall Image
%
%   M. Kutzer, 02Apr2020, USNA

%% Check input(s)
narginchk(0,1);

if nargin == 1
    saveFiles = varargin{1};
else
    saveFiles = true;
end

%% Provide status
fprintf('Generating 3D camera fov figures...\n');

%% Load Camera Calibration
filename = fullfile('calibration','data','cameraParams_20200312-evangelista-1.mat');
fprintf('\tLoading camera calibration...');
load(filename);
fprintf('[COMPLETE]\n');

%% Present results
roomIDs = {'Ri078','Ri080'};
for i = 1:numel(roomIDs)
    str = sprintf('Camera FOV, %s',roomIDs{i});
    fprintf('\tInitializing "%s"...',str);
    % Simulate camera FOV
    imageResolution = [640,480];
    sim = initCameraSim(A_c2m,imageResolution,0.5*24*12*25.4);
    set(sim.Figure,'Visible','off');
    drawnow;
    
    % Update tags
    set(sim.Figure,'Tag',sprintf('Figure, FOV %s',roomIDs{i}));
    set(sim.Axes,  'Tag',sprintf(  'Axes, FOV %s',roomIDs{i}));
    
    % Apply "correction"
    %{
    pA(1:2) = [-84,-100]./fliplr(imageResolution);
    pA(3:4) = [1.37, 1.37];
    set(sim.Axes,'Position',pA);
    %}
    
    % Adjust x and y limits?
    xlim(sim.Axes,xlim(sim.Axes)*5);
    ylim(sim.Axes,ylim(sim.Axes)*5);
    zlim(sim.Axes,zlim(sim.Axes)*3);
    
    fprintf('[COMPLETE]\n');
    
    % Load the 3D walls room model
    fname = sprintf('3D Walls, %s',roomIDs{i});
    fprintf('\tLoading "%s.fig"...',fname);
    try
        warning off
        open( fullfile('background',[fname,'.fig']) );
        drawnow;
        warning on
        fprintf('[COMPLETE]\n');
    catch
        fprintf('[FAILED]\n');
        fprintf('3D camera fov figure generation FAILED.\n')
        return
    end
    
    fprintf('\tMigrating "%s.fig" contents...',fname);
    axs = findobj(0,'Tag',sprintf('Axes, %s',roomIDs{i}));
    if isempty(axs)
        fprintf('[FAILED]\n');
        fprintf('3D camera fov figure generation FAILED.\n')
        return
    end
    
    if numel(axs) > 1
        fprintf('\n');
        warning('Multiple instances of "%s" are open, selecting first.',[fname,'.fig']);
        axs = axs(1);
    end
    hg_o = get(axs,'Children');
    fig = get(axs,'Parent');
    
    % Move contents into camera FOV
    set(hg_o,'Parent',sim.Axes);
    % Apply transformation
    theta = 0;
    set(hg_o,'Matrix',Rx(pi/2)*Rz(theta));
    drawnow;
    % Close loaded figure
    delete(fig);
    
    fprintf('[COMPLETE]\n');
    
    % Save figure
    if saveFiles
        fname = sprintf('Camera FOV, %s.fig',roomIDs{i});
        fprintf('\tSaving "%s"...',fname);
        drawnow;
        try
            saveas(sim.Figure,fname,'fig');
            fprintf('[COMPLETE]\n');
        catch
            % TODO - add failed message
            fprintf('[FAILED]\n');
        end
        
        % Delete figure
        delete(sim.Figure);
    else
        set(sim.Figure,'Visible','on');
    end
    drawnow
    
end

%% Display complete notification
fprintf('3D camera fov figure generation complete.\n');