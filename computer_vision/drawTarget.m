function [hg,ptc] = drawTarget(shape,diameter,color)
% DRAWTARGET draws a target of specified shape, size, and color and returns
% the graphics object(s) associated with the target.
%   [hg,ptc] = DRAWTARGET(shape,diameter,color) creates a shape specified
%   by a string argument whose overall size fits within a bounding circle
%   of the specified diameter in millimeters. The specified color is then 
%   used to fill the patch object that is created. Both the patch object
%   and an hgtransform parent of the patch of object are returned.
%
%   M. Kutzer, 25Mar2020, USNA