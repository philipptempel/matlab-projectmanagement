function projectStartup(nPrjNo)
% PROJECTSTARTUP ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:49:56 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : projectStartup.m 

global projects;
global rootPathScript;

% Check if there is a file 'startup' in the projects root folder (copied
% from matlabrc.m)
if ( ( exist(fullfile(projectLocate(nPrjNo), 'startup.m'), 'file') == 2 ) || ( exist(fullfile(projectLocate(nPrjNo), 'startup.m'), 'file') == 6 ) )
    % Display a message
    display('Found startup file for project. Running it...');
    
    % Try to run the startup file
    try
        run(fullfile(projectLocate(nPrjNo), 'startup.m'));
    % Running startup file failed
    catch exc
        % Forge a new exception, add the just caught exception
        exception = MException('PHILIPPTEMPEL:PrjMgmt:ProjectStartupFailed', ['Running project specific startup file failed with the following error: ' , exc.message]);
        exception = addCause(exception, exc);
        
        % And throw that new exception
        throw(exception);
    end
end








% ===== EOF ====== [projectStartup.m] ======  
