function menuAdd()
% MENUADD ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:56:45 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : menuAdd.m 

global projects;
global rootPathScript;


% Get a path to where we will add the project root
selPath = uigetdir();

% Got a path?
if selPath ~= 0
    % Substract the name of the last folder from the path provided
    [~, deepestFolder] = fileparts(selPath);

    % Ask the user for a project name with the default being set to
    % the name of the folder selected above
    sProjectName = inputdlg('Name of Project (empty or cancel to take name of folder)', 'Rename Project', 1, {deepestFolder});
    
    % Name was canceled or not provided? Then guess it from the
    % folder name
    if isempty(cell2mat(sProjectName))
        sProjectName = {deepestFolder};
    end

    % To append we will get the new index
    nNewIndex = numel(projects(:, 1)) + 1;

    % Store the project name and path within the global projects
    % variable
    projects(nNewIndex, 1) = sProjectName;
    projects(nNewIndex, 2) = {selPath};
    
    % Sort the projects in natural sort order
    [~, index] = sort_nat(projects(:, 1));
    projects(:, 1) = projects(index, 1);
    projects(:, 2) = projects(index, 2);

    % Finally save all the new data
    save(fullfile(rootPathScript, 'prjmgmt.mat'), 'projects', 'rootPathScript');
end

clear nNewPos projectName upperPath deepestFolder selPath;








% ===== EOF ====== [menuAdd.m] ======  
