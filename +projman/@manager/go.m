function go(project)
% GO goes to the given project's folder
%
%   Inputs:
%
%   PROJECT             Identifier of project to go to



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-10
% Changelog:
%   2018-02-10
%       * Initial release



%% Do your code magic here

% Get a project manager instance
pm = projman.instance();

p = pm.find(project);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
