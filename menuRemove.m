function menuRemove()
% MENUREMOVE ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:56:45 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : menuRemove.m 

global projects;
global rootPathScript;


% Got projects?
if ( ~isempty(projects) )
    
    % Get the names of projects to create a nice list dialog
    listString = projects(:, 1);
    
    selection = [];
    
    while ( isempty(selection) || ( numel(selection) == numel(listString) ) )
        % Pop open a list dialog with the project names as possible selectives
        % and some other nice UI stuff ;)
        [selection, ok] = listdlg('ListString', listString, ...
                                'SelectionMode', 'multiple', ...
                                'Name', 'Remove Project', ...
                                'PromptString', 'Please choose projects to remove', ...
                                'OKString', 'Remove', ...
                                'CancelString', 'Cancel');

        % Got a selection from the listdlg
        if ( ok == 1 )
            % Delete less projects than we have defined? That's okay
            if ( numel(selection) < numel(listString) )
                projects(selection, :) = [];

                save(fullfile(rootPathScript, 'prjmgmt.mat'), 'projects', 'rootPathScript');
                
                break;
            % Somebody tries to delete all projects, we won't allow that
            % (But for what reason actually?)
            else
                h = errordlg('Cannot delete all projects', 'Error', 'modal');
                waitfor(h);
            end
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

clear nNewPos projectName upperPath deepestFolder selPath;








% ===== EOF ====== [menuRemove.m] ======  
