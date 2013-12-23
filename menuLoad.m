function loaded = menuLoad()
% MENULOAD ... 
%  
%   ... 

%% AUTHOR    : Philipp Tempel 
%% $DATE     : 20-Dec-2013 11:47:31 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 8.2.0.701 (R2013b) 
%% FILENAME  : menuLoad.m 

global projects;
global rootPathScript;

loaded = 0;

% Got projects?
if ( ~isempty(projects) )
    
    % Get the names of projects to create a nice list dialog
    listString = projects(:, 1);
    
    % Pop open a list dialog with the project names as possible selectives
    % and some other nice UI stuff ;)
    [selection, ok] = listdlg('ListString', listString, ...
                            'SelectionMode', 'single', ...
                            'Name', 'Load Project', ...
                            'PromptString', 'Please choose a project to load', ...
                            'OKString', 'Load', ...
                            'CancelString', 'Cancel');
    
    % Got a selection from the listdlg
    if ( ok == 1 )
        % Try to load and startup the project
        try
            % Try to load the project (get its path and check whether that
            % path exists
            projectLoad(selection);
            
            % Then, check if there's a startup.m file and execute it
            % catching all the ish that might come along
            projectStartup(selection);
            
            loaded = 1;
        % Some failure happened either when loading or starting up the
        % project
        catch exc
            h = errordlg(exc.message, 'Error', 'modal');
            waitfor(h);
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








% ===== EOF ====== [menuLoad.m] ======  
