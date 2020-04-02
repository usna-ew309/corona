function tf = gitlfsCheck(varargin)
% LFSFIXCHECK checks a file for ASCII characters that indicate use of
% git-lfs.
%   tf = LFSFIXCHECK(filename) returns a "true" value if the file contains
%   git-lfs location/ID information instead of data.
%
%   tf = LFSFIXCHECK(pathname,filename)
%
%   tf = LFSFIXCHECK(pathname1,...,pathnameN,filename)
%
%   M. Kutzer, 02Apr2020, USNA

debugON = true;

%% Check input(s)
filename = fullfile(varargin{:});

%% Read file
fid = fopen(filename,'r');

gitlfsPhrase = 'git-lfs';
tline = fgets(fid);
out = strfind( lower(tline),gitlfsPhrase );

if debugON
    fprintf(2,'-------- gitlfsCheck.m VERSION 5.0 -------------\n');
    % DEBUG
    tline(end) = [];
    dispStr = tline;
    if numel(dispStr) > 30
        dispStr = dispStr(1:30);
    end
    fprintf('\n\tDEBUG gitlfsCheck.m: "%s" IN "%s"\n',gitlfsPhrase,dispStr);
end

if isempty(out)
    % File contains actual data
    tf = false;
    if debugON
        % DEBUG
        fprintf('\t\NO\n')
    end
else
    % File contains git-lfs location/ID information
    tf = true;
    if debugON
        % DEBUG
        fprintf('\t\tYES!!!\n')
    end
end