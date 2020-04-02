function gitlfsFixEW309corona
%GITLFSFIXEW309CORONA downloads necessary files from a specified location,
%replaces their git-lfs versions in an unzipped version of the EW309 Corona
%software package, and runs any/all scripts to build/replace required data.
%
%   M. Kutzer, 02Apr2020, USNA

toolboxName = 'EW309corona';

%% Define local path and file information
fileInfo = gitlfsFixEW309corona_fileInfo;

%% Check files
fprintf('Checking files for git-lfs location/ID info...\n');
for i = 1:numel(fileInfo)
    fprintf('\t%s...',fileInfo{i}{end});
    gitlfsBIN(i) = gitlfsCheck(fileInfo{i}{:});
    if gitlfsBIN(i)
        fprintf('[git-lfs File]\n');
    else
        fprintf('[Data File]\n');
    end
end

% Skip the remainder of this function if all files contain data
if ~any(gitlfsBIN)
    fprintf('No git-lfs fixes required\n');
    return
end

%% Setup temporary file directory
fprintf('Downloading the git-lfs fix for %s...',toolboxName);
tmpFolder = sprintf('lfsfix_%s',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download alternative file source(s)
url = 'https://www.usna.edu/Users/weaprcon/kutzer/_files/coursefiles/EW309supportFiles.zip';

try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
end

%% Check for successful download
if ~confirm
    error('gitlfsFix:FailedDownload','Failed to download git-lfs fix for of %s.',toolboxName);
end

%% Find base directory
srcPathBase = pname;                    % base of source path

%% Get current directory
dstPathBase = cd;                       % base of destination path

%% Replace git-lfs info files
%gitlfsBIN
fprintf('Replacing for git-lfs location/ID files...\n');
for i = 1:numel(fileInfo)
    fprintf('\t%s...',fileInfo{i}{end});
    if ~gitlfsBIN(i)
        fprintf('[SKIPPED]\n');
        continue
    end
    
    source      = fullfile(srcPathBase,fileInfo{i}{end});
    destination = fullfile(dstPathBase,fileInfo{i}{:});
    
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
end

%% Remove temporary folder
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Generate necessary data
basePath = cd;

% Create 3D walls
newPath = fullfile(basePath,'computer_vision','background');
cd(newPath);
create3Dwalls;
cd(basePath);

% Create 3D fov
newPath = fullfile(basePath,'computer_vision');
cd(newPath);
create3Dfov
cd(basePath);

%% Complete installation
fprintf('git-lfs fix complete.\n');