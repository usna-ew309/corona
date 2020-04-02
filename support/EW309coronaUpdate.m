function EW309coronaUpdate
% EW309CORONAUPDATE undates to the current version of the EW309 Corona
% Software package.
%
%   M. Kutzer, 01Apr2020, USNA

toolboxName = 'EW309corona';
installFunc = sprintf('install%s',toolboxName);
%% Setup functions
ToolboxVer     = str2func( sprintf('%sVer',toolboxName) );
installToolbox = str2func( installFunc );

%% Check current version
A = ToolboxVer;

%% Setup temporary file directory
fprintf('Downloading the %s...',toolboxName);
tmpFolder = sprintf('%s',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = 'https://github.com/usna-ew309/corona/archive/master.zip';

try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
end

%% Check for successful download
if ~confirm
    error('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
end

%% Find base directory
install_pos = strfind(fnames, installFunc );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Run git-lfs fix
gitlfsFixEW309corona;

%% Install ScorBot Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end