function row = find(project)
% FIND a project's row given the project name
%
%   Inputs:
%
%   PROJECT             Name of project to find
%
%   Outputs:
%
%   ROW                 Linear row index of project in projects table



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

% Read projects from file
taProjects = projman.Projects;

% Find the project and return its row
row = find(strcmp(taProjects.Name, project));


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
