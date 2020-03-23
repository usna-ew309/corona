%% Description
% This script provides the solution to the section "Deriving a Transfer
% function". The script is divided into two parts. Part 1 uses experimental
% data from the turret to fir a transfer function model to the dat. Part 2
% uses the high-fidelity simulator to generate "Experimental Data" then
% fits a linear model to the response. Both parts use fmincon to solve for
% the parameters of the transfer function that produce the best fit.

clear all
clc
close all


%% Method 1: Use real data to fit model

% subfolder location of experimental data
fldr = 'Turret Data/';

% filenames of positive and negative response data
fname{1} = 'EncoderData_PWM_50.xlsx';
fname{2} = 'EncoderData_PWM_neg50.xlsx';


for mm = 1:1:length(fname)
    % Import data from spreadsheet

    % read data from file
    dat = readtable([fldr fname{mm}]);
    time = [0;dat{:,2}];
    dc = [0;dat{:,1}];
    enc = [0;dat{:,3}];
    pos = [0;dat{:,4}];
    
    
    % Plot collected data
    % Position step response plot
    fig_pos(mm) = figure(mm); clf
    axs_pos = axes('Parent',fig_pos(mm));
    hold(axs_pos,'on');
    p1 = plot(axs_pos,time,pos,'-b','Linewidth',2);
    
    % Fit transfer function to position step response
    
    % Estimate data for uniform sample frequency ------------------------------
    % -> The fitting tool "fmincon" used to estimate the coefficients of the
    %    is easier to use with a uniform sample frequency.
    
    % Create a uniform time vector
    uniform_t = linspace(min(min(time)),min(max(time)),size(time,1))';
    
    % Use linear interpolation to estimate theta for the uniform time vector
    uniform_theta = interp1(time,pos,uniform_t);
    
    % Use linear interpolation to estimate duty cycle for the uniform time vector
    uniform_dc = interp1(time,dc,uniform_t);
    
    % plot uniformly re-sampled data
    p2 = plot(axs_pos,uniform_t,uniform_theta,'--r','Linewidth',2);
    
    % Fit trasfer function for position response
    data_pos = [uniform_dc uniform_t uniform_theta]; % compile real data into single matrix
    b_low = 0;
    a_low = 0;
    delta_low = 0;
    lower_bound = [b_low,a_low,delta_low];
    b_high = 100;
    a_high = 100;
    delta_high = 100;
    upper_bound = [b_high,a_high,delta_high];

    b_guess = 0.5;
    a_guess = 1;
    delta_guess = 0.08;
    init_guess = [b_guess,a_guess,delta_guess]; % provide an initial guess for a,b, and delta
    
    % use fmincon to solve for parameters
    est_params = fmincon(@(x) objFunc(x,data_pos), init_guess,[],[],[],[],lower_bound,upper_bound);
    
    % position response from fmincon
    s = tf('s');
    G_est_realDat(mm) = est_params(1)/((s+est_params(2))*(s+est_params(3)));
    [theta_estimate,~] = lsim(G_est_realDat(mm),uniform_dc,uniform_t);
    
    plot(axs_pos,uniform_t,theta_estimate,'-.m','LineWidth',2);
    
    xlabel(axs_pos,'$t$ (sec)','Interpreter','Latex');
    ylabel(axs_pos,'$\theta(t)$ (rad)','Interpreter','Latex');
    uniform_dc(end)
    title(axs_pos,['Position Step Response: Step input duty cycle ' num2str(100*uniform_dc(end),2) '%']);
    legend('Raw Data','Uniformly Sampled Data','fmincon Simulation Result')
end


G_est_realDat


%% Method 2: Use data from the simulator to fit model


% step input magnitudes (operating conditions) upon which we will fit
% models. If the models match, great! If not, we have to get creative to
% find a single model that "best" fits the full operating envelope.
opConditions = [0.5;-0.5]; 

for mm = 3:1:length(opConditions)+2
    
    % Generate "Real" data from the nonlinear simulation model
    cntrlprms.stepPWM = opConditions(mm-2);
    time = transpose(0:.01:10);
    [~,~,pos,~,~] = sendCmdtoDcMotor('step',cntrlprms,time);
    dc = cntrlprms.stepPWM*ones(size(time));
    dc(time<1) = 0;
    
    % Plot collected data
    % Position step response plot
    fig_pos(mm+2) = figure(mm+2); clf
    axs_pos = axes('Parent',fig_pos(mm+2));
    hold(axs_pos,'on');
    plot(axs_pos,time,pos,'-b','Linewidth',2);
    
    
    % Fit transfer function to position step response
    
    % Estimate data for uniform sample frequency ------------------------------    
        
    % Fit trasfer function for position response
    data_pos = [dc time pos]; % compile real data into single matrix
    b_low = 0;
    a_low = 0;
    delta_low = 0;
    lower_bound = [b_low,a_low,delta_low];
    b_high = 100;
    a_high = 100;
    delta_high = 100;
    upper_bound = [b_high,a_high,delta_high];

    b_guess = 0.5;
    a_guess = 1;
    delta_guess = 0.08;
    init_guess = [b_guess,a_guess,delta_guess]; % provide an initial guess for a,b, and delta
    
    % use fmincon to solve for parameters
    est_params = fmincon(@(x) objFunc(x,data_pos), init_guess,[],[],[],[],lower_bound,upper_bound);
    
    % position response from fmincon
    s = tf('s');
    G_est_simDat(mm-2) = est_params(1)/((s+est_params(2))*(s+est_params(3)));
    [theta_estimate,~] = lsim(G_est_simDat(mm-2),dc,time);
    
    plot(axs_pos,time,theta_estimate,'-.m','LineWidth',2);
    xlabel(axs_pos,'$t$ (sec)','Interpreter','Latex');
    ylabel(axs_pos,'$\theta(t)$ (rad)','Interpreter','Latex');
    title(axs_pos,['Position Step Response: Step input duty cycle ' num2str(100*dc(end)) '%']);
    legend('Raw Data','fmincon Simulation Result')
end


G_est_simDat

