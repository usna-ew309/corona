%% SCRIPT_TestWait
clear all;
close all;
clc;

%% Run
g = gifwait(0,'Please wait...');
while true
    g = gifwait(g);
    if isempty(g)
        break
    end
end