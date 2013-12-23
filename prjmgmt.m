function prjmgmt(varargin)
% PRJMGMT ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 08:18:44 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : prjmgmt.m 

% Make these variables global
global projects;
global rootPathScript;

% Initialize the projects array to an empty cell array
projects = cell(0, 2);

% Get the root path script variable by guessing where this file is stored
% and executed at, then grabbing its filepath and replacing the filename
% with empty spaces
cThisFilename = mfilename();
[cUpperPath, cDump] = fileparts(mfilename('fullpath'));
rootPathScript = strrep(cUpperPath, cThisFilename, '');

% Now, check if we have the data we need to run the project managemet script
if ( exist(fullfile(rootPathScript, 'prjmgmt.mat'), 'file') )
    load(fullfile(rootPathScript, 'prjmgmt.mat'));
end

% And off we go
while true
    % Main menu
    choice = menuMain();
    
    switch ( choice )
        % Load Project
        case 1
            % To check whether a project was loaded
            loaded = menuLoad();
            
            % If a project was loaded, "project management" will end
            if ( loaded )
                break;
            end
        % Add Project
        case 2
            menuAdd();
        % Update Project
        case 3
            menuUpdate();
        % Remove Project
        case 4
            menuRemove();
        % Cancel
        case 5
            break;
        otherwise
            menuLoad()
            
            break;
    end
end

clear all



% ===== EOF ====== [prjmgmt.m] ======  