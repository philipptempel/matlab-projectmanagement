function path = projectLocate(nPrjNo)
% PROJECTLOCATE ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:48:37 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : projectLocate.m 

global projects;
global rootPathScript;

% Warp locating a project into a try-catch block so we will avoid any ugly
% error messages
try
    % Get the path from the projects variable and cast to mat
    path = cell2mat(projects(nPrjNo, 2));

    % Check the path exists as a directory
    if ~exist(path, 'dir')
        % Path is no directory, so we will forge a new exception
        exception = MException('PHILIPPTEMPEL:PrjMgmt:PathNotAvailable', 'Path to selected project was not found.');
        
        % And throw that thing
        throw(exception);
    end
% Catch any exception that might have arisen
catch exc
    % And rethrow that exception
    rethrow(exc);
end






% ===== EOF ====== [projectLocate.m] ======  
