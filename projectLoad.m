function projectLoad(nPrjNo)
% PROJECTLOAD ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:47:50 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : projectLoad.m 

global projects;
global rootPathScript;

% Warp loading a project into a try-catch block so we will avoid any ugly
% error messages
try
    % Get the projects path (will check for existing project folder, if not
    % throws an exception)
    path = projectLocate(nPrjNo);

    % And change to that path
    cd(path);
catch exc
    rethrow(exc);
end

clear path exc;








% ===== EOF ====== [projectLoad.m] ======  
