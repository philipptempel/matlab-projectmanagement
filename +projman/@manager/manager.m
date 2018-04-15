classdef manager < handle
    % MANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    
    %% PUBLIC PROPERTIES
    properties
        
        Projects
        
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
        
        
%         function varargout = subsref(this, s)
%             %% SUBSREF
%             switch s(1).type
%                 case '.'
% %                     if length(s) == 1
% %                         % Implement this.PropertyName
% %                         ...
%                     if length(s) == 2 && strcmp(s(2).type, '()')
%                         % Implement this.PropertyName(indices)
%                         % Check if the called index is a real property of this
%                         % object
%                         if isprop(this, s(1).subs)
%                             % Pass down to built-in subsref function
%                             [varargout{1:nargout}] = builtin('subsref', this, s);
%                         % Here we are handling passing a function call to the
%                         % matching project
%                         else
%                             % Name of the project being called
%                             chProj = s(2).subs{1};
%                             % Name of function to call on project
%                             chFunc = s(1).subs;
%                             try
%                                 % Find the project
%                                 p = this.find(chProj);
%                                 % Call the function on the child
%                                 [varargout{1:nargout}] = p.(chFunc);
%                             catch me
%                                 throwAsCaller(me);
%                             end
%                         end
%                     else
%                         [varargout{1:nargout}] = builtin('subsref', this, s);
%                     end
%                 case '()'
%                     if length(s) == 1
%                         % Implement this(name)
%                         try
%                             % Get project name
%                             chProj = s(1).subs{1};
%                             
%                             % And find the project
%                             [varargout{1:nargout}] = this.find(chProj);
%                         catch me
%                             throwAsCaller(me);
%                         end
%                     elseif length(s) == 2 && strcmp(s(2).type, '.')
%                         % Implement this(ind).PropertyName
%                         try
%                             % Get project name
%                             chProj = s(1).subs{1};
%                             % Function to call
%                             chFunc = s(2).subs{1};
%                             
%                             % Handle
%                             try
%                                 % And find the project
%                                 p = this.find(chProj);
%                                 % Call the function
%                                 p.(chFunc);
%                             catch me
%                                 throwAsCaller(me);
%                             end
%                             
%                         catch me
%                             throwAsCaller(me);
%                         end
%                     else
%                         % Use built-in for any other expression
%                         [varargout{1:nargout}] = builtin('subsref', this, s);
%                     end
%                 case '{}'
%                     % Use built-in for any other expression
%                     [varargout{1:nargout}] = builtin('subsref', this, s);
%                 otherwise
%                     error('Not a valid indexing expression')
%             end
%         end
        
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
