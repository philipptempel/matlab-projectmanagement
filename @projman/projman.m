classdef projman
    % PROJMAN is a very simple MATLAB based project management tooling
    
    properties ( Constant )
        ProjectsFile = 'projects.csv'
    end
    
    properties ( Constant, Dependent )
        Projects
    end
    
    methods ( Static )
        add(id)
        % ADD a new project to the list of projects
        
        cd(id)
        % CD to a project
        
        find(project)
        % FIND a project's ID
        
        finish(id)
        % FINISH finishes a project
        
        load(id)
        % LOAD the projects from the hard drive
        
        remove(id)
        % REMOVE a project from the list of projects
        
        save(id)
        % SAVE the projects to the hard drive
        
        startup(id)
        % STARTUP starts a project
        
        update(id, project)
        % UPDATE details of a project
    end
    
    methods % DEPENDENT METHODS
        
        function p = get.Projects()
            % GET.PROJECTS gets the projects file\
            
            chFile = fullpath(fullfile(fileparts(mfilename('fullpath')), '..', projman.ProjectsFile));
            
            % If there is a project CSV file, load it
            if 2 == exist(chFile, 'file')
                stContent = readtable(chFile);
            % No file exists, so create an empty table
            else
                stContent = table({}, {}, {}, {}, 'VariableNames', {'ID', 'Name', 'Directory', 'Dependencies'});
            end
            
            % Return this project
            p = stContent;
        end
        
    end % DEPENDENT METHODS
    
end
