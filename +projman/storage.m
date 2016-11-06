function [file, folder] = storage()
% STORAGE returns the filename that identifies this computer's project storage
%
%   Outputs:
%
%   FILE        Character array of the fully qualifying filename of this
%       computer's project storage file.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-11-05
% Changelog:
%   2016-11-05
%       * Initial release



%% Assertion
% Allow no input argument
narginchk(0, 0);
% Allow zero to 2 output arguments
nargoutchk(0, 2);



%% Do your code magic here

% File name is built up from the computer name and user name connected through a
% single hyphen (since matlab.lang.makeValidName only allows underscores we know
% that the hyphen separates computer name from user name).
file = sprintf('%s-%s.csv', matlab.lang.makeValidName(projman.computername()), matlab.lang.makeValidName(projman.username()));

% Folder is one directory above this file's directory
folder = fullpath(fullfile(fileparts(mfilename('fullpath')), '..'));



end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
