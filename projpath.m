function p = projpath()
% PROJPATH returns the project's paths
%
%   P = PROJPATH() returns a cell array of all paths needed to be on MATLAB's
%   search path for this project.
%
%   Outputs:
%
%   P                   1xK cell array of paths this project requires to be on
%                       MATLAB's search path



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-05
% Changelog:
%   2018-05-05
%       * Initial release



%% Setup the paths
% Directory of this file
chPath = fileparts(mfilename('fullpath'));

% Build paths
p = { ...
    chPath ...
};


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
