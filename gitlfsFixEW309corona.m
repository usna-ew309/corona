function gitlfsFixEW309corona
%GITLFSFIXEW309CORONA downloads necessary files from a specified location,
%replaces their git-lfs versions in an unzipped version of the EW309 Corona
%software package, and runs any/all scripts to build/replace required data.
%
%   M. Kutzer, 02Apr2020, USNA

toolboxName = 'EW309corona';
installFunc = sprintf('install%s',toolboxName);

%% Define local path and file information
fileInfo{ 1} = {'ballistics','MVfit.mat'};
fileInfo{ 2} = {'computer_vision','ColorStats.mat'};
fileInfo{ 3} = {'computer_vision','background','data','Ri078_NE_Wall.JPG'};
fileInfo{ 4} = {'computer_vision','background','data','Ri078_NW_Wall.JPG'};
fileInfo{ 5} = {'computer_vision','background','data','Ri078_SE_Wall.JPG'};
fileInfo{ 6} = {'computer_vision','background','data','Ri078_SW_Wall.JPG'};
fileInfo{ 7} = {'computer_vision','background','data','Ri080_NE_Wall.JPG'};
fileInfo{ 8} = {'computer_vision','background','data','Ri080_NW_Wall.JPG'};
fileInfo{ 9} = {'computer_vision','background','data','Ri080_SE_Wall.JPG'};
fileInfo{10} = {'computer_vision','background','data','Ri080_SW_Wall.JPG'};

%% Check files
fprintf('Checking files for git-lfs location/ID info...\n');
for i = 1:numel(fileInfo)
    fprintf('%s...',fileInfo{i}{end});
    bin(i) = gitlfsCheck(fileInfo{i}{:});
    if bin(i)
        fprintf('[git-lfs File]\n');
    else
        fprintf('[Data File]\n');
    end
end

% Skip the remainder of this function if all files contain data
if ~any(bin)
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
install_pos = strfind(fnames, installFunc );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

install_pos
sIdx
cIdx
fnames
fnames{cIdx}
srcPathBase = fnames{cIdx}(1:sIdx-1);   % base of source path

%% Get current directory
dstPathBase = cd;                       % base of destination path

%% Replace git-lfs info files
fprintf('Replacing for git-lfs location/ID files...\n');
for i = 1:numel(fileInfo)
    fprintf('%s...',fileInfo{i}{end});
    if ~bin(i)
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