function menuUpdate()
% MENUUPDATE ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:47:31 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : menuUpdate.m 

global projects;
global rootPathScript;

% Got projects?
if ( ~isempty(projects) )
    
    % Get the names of projects to create a nice list dialog
    listString = projects(:, 1);
    
    % Pop open a list dialog with the project names as possible selectives
    % and some other nice UI stuff ;)
    [selection, ok] = listdlg('ListString', listString, ...
                            'SelectionMode', 'single', ...
                            'Name', 'Update Project', ...
                            'PromptString', 'Please choose project to update', ...
                            'OKString', 'Update', ...
                            'CancelString', 'Cancel');
    
    % Got a selection from the listdlg
    if ( ok == 1 )
        % Get a new path
        selPath = uigetdir(projectLocate(2));
        
        % Got a path
        if ( ~isempty(selPath) )
            % Substract the name of the last folder from the path provided
            [upperPath, deepestFolder] = fileparts(selPath);
            
            % Ask the user for a project name with the default being set to
            % the name of the folder selected above
            sProjectName = inputdlg('Name of Project (empty or cancel to take name of folder)', 'Rename Project', 1, projectName(2));
            
            % Name was canceled or not provided? Then guess it from the
            % folder name
            if ( isempty(cell2mat(sProjectName)) )
                sProjectName = {deepestFolder};
            end

            % Store the project name and path within the global projects
            % variable
            projects(selection, 1) = sProjectName;
            projects(selection, 2) = {selPath};

            % Finally save all the new data
            save(fullfile(rootPathScript, 'prjmgmt'), 'projects', 'rootPathScript');
        end
    end
% Ain't got no projects :(
else
    % Display a notice that there are no projects
    h = errordlg('To continue, please add a project on the following screen.', 'No projects found!', 'modal');
    waitfor(h);
    
    % And call the menuAdd function to add a new project
    menuAdd();
end

clear listString selection ok;








% ===== EOF ====== [menuUpdate.m] ======  
