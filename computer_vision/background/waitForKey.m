function waitForKey(fig,keyIN)
% WAITFORKEY pauses the execution of MATLAB until a specified key is
% pressed on the keyboard. 
%   WAITFORKEY(fig,keyIN) uses a simple 'WindowKeyPressFcn' for the 
%   designated figure handle (fig) to pause MATLAB's execution until the 
%   specified key (keyIn) is pressed. 
%
%   Note that this function assumes lowercase keys only. 
%
%   M. Kutzer, 18Mar2020, USNA

global stopFlag key

key = lower(keyIN);

stopFlag = false;

set(fig,'WindowKeyPressFcn',@simpleKeyPressCallback);

while ~stopFlag
    % GO!
    drawnow
end

end

function simpleKeyPressCallback(src, callbackdata)

global stopFlag key

switch lower(callbackdata.Key)
    case key
        stopFlag = true;
    otherwise
        stopFlag = false;
end

end