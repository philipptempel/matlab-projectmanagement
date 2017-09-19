function cd(project)
% CD switches to the working directory of the given project
%
%   Inputs:
%
%   PROJECT             Description of argument PROJECT



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2017-09-19
% Changelog:
%   2017-09-19
%       * Initial release



%% Do your code magic here
% Valdiate argument
try
    validateattributes(project, {'char'}, {'nonempty'}, mfilename, 'project');
catch me
    throwAsCaller(me);
end

% Find the project
dRow = projman.find(project);

% Assert we found a project
assert(~isempty(dRow), 'PHILIPPTEMPEL:MATPROJ:PROJMAN:CD:InvalidProject', 'Project %s not found', project);





end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
