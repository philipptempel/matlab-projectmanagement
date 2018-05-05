function install()
% INSTALL Matlab Project Management on your machine



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-05-05
% Changelog:
%   2018-05-05
%       * Initial release



%% Install script

% We will add the current directory to MATLAB's search path
p = projpath();
addpath(p{:});

% Get an instance of the project manager
pjm = projman.manager();

% Up until here there should be no projects on the manager, so we will just add
% this folder as the first project
p = projman.project(fullfile(pwd), 'MATLAB Project Manager');

% Add the newly created project to the project manager
pjm.Projects = p;

% And save the projects manager
save(pjm);


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
