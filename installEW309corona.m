function installEW309corona(replaceExisting)

%% Install/Update required toolboxes
installSupportToolboxes;

%% Assign tool/toolbox specific parameters
dirName = 'ew309corona';

%% Check inputs
if nargin == 0
    replaceExisting = [];
end

%% Installation error solution(s)
adminSolution = sprintf(...
    ['Possible solution:\n',...
    '\t(1) Close current instance of MATLAB\n',...
    '\t(2) Open a new instance of MATLAB "as administrator"\n',...
    '\t\t(a) Locate MATLAB shortcut\n',...
    '\t\t(b) Right click\n',...
    '\t\t(c) Select "Run as administrator"\n']);

%% Check for toolbox directory
toolboxRoot = fullfile(matlabroot,'toolbox',dirName);
isToolbox = exist(toolboxRoot,'file');
if isToolbox == 7
    % Apply replaceExisting argument
    if isempty(replaceExisting)
        choice = questdlg(sprintf(...
            ['MATLAB Root already contains the EW309corona.\n',...
            'Would you like to replace the existing toolbox?']),...
            'Replace Existing?','Yes','No','Yes');
    elseif replaceExisting
        choice = 'Yes';
    else
        choice = 'No';
    end
    % Replace existing or cancel installation
    switch choice
        case 'Yes'
            % TODO - check if NatNet SDK components are running and close
            % them prior to removing directory
            rmpath(toolboxRoot);
            [isRemoved, msg, msgID] = rmdir(toolboxRoot,'s');
            if isRemoved
                fprintf('Previous version of EW309corona removed successfully.\n');
            else
                fprintf('Failed to remove old EW309corona folder:\n\t"%s"\n',toolboxRoot);
                fprintf(adminSolution);
                error(msgID,msg);
            end
        case 'No'
            fprintf('EW309corona currently exists, installation cancelled.\n');
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Create EW309corona Toolbox Path
[isDir,msg,msgID] = mkdir(toolboxRoot);
if isDir
    fprintf('EW309corona folder created successfully:\n\t"%s"\n',toolboxRoot);
else
    fprintf('Failed to create EW309corona Toolbox folder:\n\t"%s"\n',toolboxRoot);
    fprintf(adminSolution);
    error(msgID,msg);
end

%% Migrate toolbox folder contents
toolboxContent{1} = 'ballistics';
filenames{1} = {...
    'MVfit.mat',...         % Fit information
    'MVfit2MVstats.m',...   % Fit to stats conversion
    'getShotPattern.m'};    % Shot pattern generator
dataFiles(1).Directory = {};
dataFiles(1).Filenames = {};

toolboxContent{2} = 'computer_vision';
filenames{2} = {...
    'ColorStats.mat',...
    'Camera FOV, Ri078.fig',... 
    'Camera FOV, Ri080.fig',... 
    'getTargetImage.m',...          % !   Begin getTargetImage
    'createCrosshair.m',...         % x
    'createEW309RoomFOV.m',...      % x
    'createTarget.m',...            % x
    'createTargetColorPatch.m',...  % x
    'getDefaultsEW309RoomFOV.m',... % x
    'getFOVSnapshot.m',...          % x
    'placeTarget.m',...             % x
    'setupTurretAndTarget.m',...    % x   --End getTargetImage
    'getShotPatternImage.m',...     % !   Begin getShotPatternImage
    'renderShotPattern.m',...       %     --End getShotPatternImage
    'getCalibrationImage.m'};       % !   Begin getCalibrationImage
dataFiles(2).Directory = {};
dataFiles(2).Filenames = {};

toolboxContent{3} = 'turret-movement_simulation';
filenames{3} = {...
    'objFunc.m',...         % For fmincon and turret modeling
    'sendCmdtoDcMotor.m'};  % For "moving" the turret
dataFiles(3).Directory = {};
dataFiles(3).Filenames = {};

toolboxContent{4} = 'support';
filenames{4} = {...
    'EW309coronaUpdate.m',...
    'EW309coronaVer.m'};
dataFiles(4).Directory = {};
dataFiles(4).Filenames = {};

%% Migrate files
for tCon = 1:numel(toolboxContent)
    % Check if subdirectoy is a folder
    if ~isfolder(toolboxContent{tCon})
        error(sprintf(...
            ['Change your working directory to the location of "installEW309corona.m".\n',...
            '\n',...
            'If this problem persists:\n',...
            '\t(1) Unzip your original download of "EW309corona" into a new directory\n',...
            '\t(2) Open a new instance of MATLAB "as administrator"\n',...
            '\t\t(a) Locate MATLAB shortcut\n',...
            '\t\t(b) Right click\n',...
            '\t\t(c) Select "Run as administrator"\n',...
            '\t(3) Change your "working directory" to the location of "installEW309corona.m"\n',...
            '\t(4) Enter "installEW309corona" (without quotes) into the command window\n',...
            '\t(5) Press Enter.']));
    end
    
    % Migrate files
    files = filenames{tCon};
    wb = waitbar(0,sprintf('Copying EW309corona %s contents...',upper(toolboxContent{tCon})));
    n = numel(files);
    fprintf('Copying EW309corona %s contents:\n',upper(toolboxContent{tCon}));
    for i = 1:n
        % source file location
        source = fullfile(toolboxContent{tCon},files{i});
        % destination location
        destination = toolboxRoot;
        
        fprintf('\t%s...',files{i});
        [isCopy,msg,msgID] = copyfile(source,destination,'f');
        
        if isCopy == 1
            fprintf('[Complete]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
        
        waitbar(i/n,wb);
    end
    
    % Migrate subdirectories
    n = numel( dataFiles(tCon).Directory );
    for i = 1:n
        subfolder = dataFiles(tCon).Directory{i};
        fprintf('\t%s...',subfolder);
        nDestination = fullfile(toolboxRoot, subfolder);
        [isDir,msg,msgID] = mkdir(nDestination);
        
        if isDir
            fprintf('[Complete]\n');
            m = numel( dataFiles(tCon).Filenames{i} );
            for j = 1:m
                subfilename = dataFiles(tCon).Filenames{i}{j};
                fprintf('\t\t%s...',subfilename);
                
                source = fullfile(toolboxContent{tCon},subfolder,subfilename);
                [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                
                if isCopy == 1
                    fprintf('[Complete]\n');
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
                
            end
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    
    delete(wb);
    drawnow;
end

%% Save toolbox path
%addpath(genpath(toolboxRoot),'-end');
addpath(toolboxRoot,'-end');
savepath;

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');

end