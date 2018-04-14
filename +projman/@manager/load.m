function load(name, depend)
% LOAD loads a project and its dependencies by its name or identifier
%
%   Inputs:
%
%   NAME                Character array representing the project name or
%                       identifier.



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-01-25
% Changelog:
%   2018-01-25
%       * Update to use a 'projects.mat' file with projects stored as their own
%       structure (with fields 'Path' and 'Dependencies')
%   2017-09-16
%       * Initial release



%% Validate arguments
narginchk(1, 2);
nargoutchk(0, 0);

% Default argument value for 'depend'
if nargin == 1 || 1 ~= exist('depend', 'var') || isempty(depend)
    depend = 0;
end



%% Do your code magic here

% Persistent storage of all projects
persistent stProjects ceProjectnames

% If first time use, no projects list exists
if isempty(stProjects)
    % Load the projects list
    stProjects = load(fullfile(fileparts(mfilename('fullpath')), 'projects.mat'));
    
    % Get all project names
    ceProjectnames = fieldnames(stProjects);
end

% Find the project identifier
idxProject = find(strcmpi(name, ceProjectnames), 1, 'first');

% Check we found a project
if isempty(idxProject)
    throw(MException('PHILIPPTEMPEL:MATLAB:PROJMAN:LOAD:InvalidProject', 'Invalid project. No definition for project %s found.', name));
end

% Get the project's structure
stProject = stProjects.(ceProjectnames{idxProject});

% Read dependencies
if isfield(stProject, 'Dependencies')
    ceDependencies = stProject.Dependencies;
else
    ceDependencies = {};
end

% If there are dependencies
if ~isempty(ceDependencies)
    % Load each single dependency @TODO ensure we won't end up in a recursive
    % dead lock here
    for iDep = 1:numel(ceDependencies)
        try
            projman.load(ceDependencies{iDep}, true);
        catch me
            warning(me.identifier, me.message);
        end
    end
end

% If we are loading this project as a dependency, we will only run its startup
% file, not change directory
chStartupfilePath = fullfile(stProject.Path, 'startup.m');
if 2 == exist(chStartupfilePath, 'file')
    run(chStartupfilePath);
end


% If we aren't loading this project as a dependency, we will laslty change the
% working directory to the new project
if ~depend
    cd(stProject.Path);
end


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
