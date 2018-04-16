classdef manager < handle
    % MANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    
    %% PUBLIC PROPERTIES
    properties
        
        Projects
        
    end
    
    
    %% WRITE-PROTECTED PROPERTIES
    properties ( SetAccess = protected )
        
        Loaded
        
    end
    
    
    %% STATIC METHODS
    methods ( Static )
        
        function f = filename()
            %% FILENAME returns the computer aware filename of the projects file
            
            
            % Call the system command `hostname` and check its result status
            [dStatus, chComputername] = system('hostname');

            % If the previous command call failed, we will need to infer the computer name
            % from an environment variable
            if dStatus ~= 0
                % On windows
                if ispc
                    chComputername = getenv('COMPUTERNAME');
                % On anything else
                else      
                    chComputername = getenv('HOSTNAME');
                end
            end

            % Build the filename
            f = fullfile(fileparts(which('projman.manager')), '..', sprintf('%s.mat', matlab.lang.makeValidName(chComputername)));
            
        end
        
    end
    
    
    %% GENERAL METHODS
    methods
        
        function this = manager()
            %% MANAGER creates a new manager instance
            
            
            % Load the projects
            this.load_projects_();
            
            
        end
        
        
        function p = find(this, name)
            %% FIND a single project by name
            
            
            try
                % Find matching names
                idxMatches = ismember({this.Projects.Name}, name);
                
                % Make sure we found a project
                assert(any(idxMatches), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project could not be found because it does not exist or names are too ambigious');
                
                % And return the data
                p = this.Projects(idxMatches);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function go(this, name)
            %% GO to a project's folder
            
            
            try
                % Find project
                p = this.find(name);
                
                % Go to project
                p.go();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function activate(this, name)
            %% ACTIVATE a project
            
            
            try
                % Find project
                p = this.find(name);
                
                % Activate project
                p.activate();
                
                % And mark it as loaded
                this.Loaded = horzcat(this.Loaded, p);
            catch me
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    %% OVERRIDERS
    methods
        
        function save(this)
            %% SAVE this project manager instance
            
            
            % Save the projects to a file
            try
                % Get the projects
                p = this.Projects;
                
                % Save above variable into the file
                save(projman.manager.filename(), 'p');
                
                % Free some memory
                clear('p');
            catch me
                throwAsCaller(me);
            end
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        
        function load_projects_(this)
            %% LOAD_PROJECTS_ loads the projects for this file
            
            
            % Load the projects
            try
                % Create a matfile object
                moFile = matfile(projman.manager.filename());
                
                % Get the variables inside the matfile
                stVariables = whos(moFile);
                
                % If there are variables, we will get them
                if numel(stVariables)
                    % Find the first variable being of type 'projman.project'
                    [~, idx] = find(strcmp({stVariables.class}, 'projman.project'), 1, 'first');
                    
                    % Get the projects and assign them
                    this.Projects = moFile.(stVariables(idx).name);
                end
            catch me
                % Init empty projects array
                this.Projects = projman.project.empty(1, 0);
            end
            
        end
        
    end
    
end
