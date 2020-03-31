function [xPositions,yPositions] = fireShots(range,numShots)
% TODO!! FINISH SUMMARY


% ballistics statistics from the processing code
px = [.0042 5.2635]; % fitting parameters on x_bias
py = [.0622 -11.3554]; % fitting parameters on y_bias
psx = [.0135 0]; % fitting parameters on x standard deviation
psy = [.0044 1.9758]; % fitting parameters on y standard deviation

xPositions = normrnd(px(1)*range+px(2),psx(1)*range+psx(2),[numShots,1]);
yPositions = normrnd(py(1)*range+py(2),psy(1)*range+psy(2),[numShots,1]);
end

