%% SCRIPT_FormatBallisticsData
% This script formats the ballistics data for use in createBallisticMVfit.m
%
%   M. Kutzer, 01Apr2020, USNA
clear all
close all
clc

%% Import Data Set 1
pname = 'data';

% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "C2:D40";

% Specify column names and types
opts.VariableNames = ["xcm", "ycm"];
opts.SelectedVariableNames = ["xcm", "ycm"];
opts.VariableTypes = ["double", "double"];

distances = [173, 274, 323, 584];
X = {};
Y = {};
Z = {};
for i = 1:numel(distances)
    Z{end+1} = distances(i);
    
    fname = sprintf('%dcentimeters.xlsx',distances(i));
    data = readtable( fullfile(pname,fname), opts, "UseExcel", false);
    
    X{end+1} = data.xcm;
    Y{end+1} = data.ycm;
    
    % Remove NaN values
    bin = isnan(X{end});
    X{end}(bin) = [];
    Y{end}(bin) = [];
end

clearvars -except X Y Z