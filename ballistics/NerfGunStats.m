function [x_bar,y_bar,theta,num_shots] = NerfGunStats(range,target_radius,p_one,px,py,pSp)
% NerfGunStats generate the x and y bias corrections for a specific range 
% as well as the theta (angle) correction and computes the number of shots
% required for a given range, target radius, and probabilty of at least one hit

%Inputs:
%       range:          distance betweent the NERF gun and the target (cm)
%       
%       target_radius:  radius of the target (cm) - must be the
%       same as range!!)
%       p_one:          probability of at least one hit
%
%   Optional Inputs:
%       px:             polyfit data from the x bias 
%       py:             polyfit data from the y bias
%       Sp:             polyfit data from the precision error

%Outputs:          
%       x_bar:          bias correction in the x-directon
%       y_bar:          bias correction in the y-direction
%       theta:          angle to turn the gun to correct for x_bias
%       Num_shots:      number of shots required for a p_one percent
%       probability of at least one hit

% This function requires the polyfit data from the Process_Ballistics_Data.
% Specifically it needs the polyfit from the x and y bias as well as the
% Precision Error px, py, Sp.  Students can either hard code it into this
% function or bring it in with their inputs


% Example usage (bring in the polyfit data as an input to the function):
% [x_bar,y_bar,theta,num_shots] = NerfGunStats(range,target_radius,p_one,px,py,Sp)

% T. Severson, USNA, EW309, AY2020

%
% px = [0.4230,5.263]; %slope and y-intercept
% py = [6.215,-11.358]; %slope and y-intercept
% Sp = [0.8954,0.7983]; %slope and y-intercept

%compute the bias in the x-direction (x_bar)
x_bar = px(1)*range+px(2);

%compute the bias in the y-direction (y_bar)
y_bar = py(1)*range+py(2);

%computer the precision error (Sp)
Sp = pSp(1)*range+pSp(2);

%compute the bias correction angle (theta) in radians
theta = atan(x_bar/range);

%computer the number of shots required for a given probability of at least one hit

k = (target_radius)/Sp; %scale factor is k, and the CEP is the diameter of the target
p_hit = 1-exp(-0.5*(k^2)); %probability of single shot hit
num_shots = ceil(log(1-p_one)/log(1-p_hit));









