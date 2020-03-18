function waitForKey(fig,keyIN)

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