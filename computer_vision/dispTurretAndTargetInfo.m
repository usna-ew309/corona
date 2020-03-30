function txt = dispTurretAndTargetInfo(varargin)
% DISPTURRETANDTARGETINFO displays the information available in the
% targetSpecs struct and turretSpecs struct in the EW309 simulated camera
% FOV.
%   txt = dispTurretAndTargetInfo(range,targetSpecs,turretSpecs) initializes the
%   display and displays the information provided.
%
%   txt = dispTurretAndTargetInfo(txt,range,targetSpecs,turretSpecs) updates the
%   display with the information provided.
%
%   M. Kutzer, 29Mar2020, USNA

%% Parse Inputs 
narginchk(3,4);
if nargin == 3
    axs = axes('Parent',gcf,'Units','Normalized','Position',[0,0.9,0.1,0.1]);
    txt = nan;
    range = varargin{1};
    targetSpecs = varargin{2};
    turretSpecs = varargin{3};
end

if nargin == 4
    txt = varargin{1};
    if ishandle(txt)
        axs = get(txt,'Parent');
    else
        axs = axes('Parent',gcf,'Units','Normalized','Position',[0,0.9,0.1,0.1]);
        txt = nan;
    end
    range = varargin{2};
    targetSpecs = varargin{3};
    turretSpecs = varargin{4};
end
xlim(axs,[0,1]);
ylim(axs,[0,1]);

%% Create string
str = sprintf([...
    'Range: %6.2fft\n\n',...
    'Target Info:\n',...
    '- Diameter:    %6.2fin\n',...
    '- Horiz. Bias: %6.2fft\n',... 
    '- Vert.  Bias: %6.2fft\n',...
    '- Wobble:      %6.2fdeg\n',...
    '- Color: "%s"\n\n',...
    'Turret Info:\n',...
    '- Horiz. Offset: %6.2fft\n',...
    '- Vert.  Offset: %6.2fft\n',...
    '- Angle:         %6.2fdeg'],...
    range/(25.4*12),...
    targetSpecs.Diameter/25.4, targetSpecs.HorizontalBias/(25.4*12),...
    targetSpecs.VerticalBias/(25.4*12), rad2deg(targetSpecs.Wobble),...
    targetSpecs.Color,...
    turretSpecs.HorizontalOffset/(25.4*12),...
    turretSpecs.VerticalOffset/(25.4*12),rad2deg(turretSpecs.Angle));

%% Display text 
if ~ishandle(txt)
    txt = text(axs,0,1,str,'BackgroundColor','w','Color','k',...
        'HorizontalAlignment','left','VerticalAlignment','top',...
        'FontSize',8);
else
    set(txt,'String',str);
end