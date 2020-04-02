function gitlfsFixEW309corona_makeZip
%GITLFSFIXEW309CORONA_MAKEZIP creates EW309supportFiles.zip containing the
%files that are part of gitlfsFixEW309corona.m
%
%   M. Kutzer, 02Apr2020, USNA

% File should be added to:
%   'https://www.usna.edu/Users/weaprcon/kutzer/_files/coursefiles/EW309supportFiles.zip';

fileInfo = gitlfsFixEW309corona_fileInfo;

fname = 'EW309supportFiles.zip';
pnameTMP = 'gitlfsFix_TMP';

[isDir,msg,~] = mkdir(pnameTMP);
% TODO - check isDir & msg
for i = 1:numel(fileInfo)
    source = fullfile(fileInfo{i}{:});
    destination = fullfile(pnameTMP,fileInfo{i}{end});
    
    [isCopy,msg,~] = copyfile(source,destination,'f');
    % TODO - check isCopy & msg
    
    % Append filenames
    filenames{i} = fileInfo{i}{end};
end

curPath = cd;

cd(pnameTMP);
zippedFiles = zip(fname,filenames);
cd(curPath);

source = fullfile(pnameTMP,fname);
destination = fname;
[isCopy,msg,~] = copyfile(source,destination,'f');
% TODO - check isCopy & msg

[ok,msg] = rmdir(pnameTMP,'s');
% TODO - check ok & msg