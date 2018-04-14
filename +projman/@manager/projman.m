classdef (Sealed) projman
    % PROJMAN is a MATLAB-based project dependencies manager
    
    properties
        
        Projects
        
    end
    
    methods ( Access = protected )
        
        function this = projman(varargin)
            %% PROJMAN creates a new PROJMAN instance
            
            
            try
                % PROJMAN()
                % PROJMAN(FILENAME)
                narginchk(0, 1);
                
                % P = PROJMAN()
                nargoutchk(1, 1);
            catch me
                throwAsCaller(me);
            end
            
            % Get the name of the file to load projects from
            if nargin == 0
                % Default to a file specific to this computer
                chProjects_File = projman.filename();
            end
            
            % Filename as first argument
            if nargin > 0
                chProjects_File = varargin{1};
            end
            
            % Check if the file has a folder and a file extension
            [chProjects_Folder, chProjects_Name, chProjects_Ext] = fileparts(chProjects_File);
            % Check for empty folder name
            if isempty(chProjects_Folder)
                chProjects_Folder = fileparts(which('projman'));
            end
            % Check for empty file extension
            if isempty(chProjects_Ext)
                chProjects_Ext = '.mat';
            end
            % Build the "corrected" file name
            chProjects_File = fullfile(chProjects_Folder, [chProjects_Name, chProjects_Ext]);
            
            % Now, just load the projects file
            try
                this.Projects = load(chProjects_File);
            % Failed loading the project's file so create a sample one
            catch me
                this.Projects = this.empty_projects_();
            end
            
        end
        
    end
    
    
    
    %% STATIC METHODS
    methods ( Static )
        
        function unload(name)
            %% UNLOAD project i.e., remove it and its dependencies from the PATH
            
            
            projman.instance.unload_(name)
            
        end
        
        
        function start(name)
            %% START a project i.e., LOAD it and GO to folder
            
            
            projman.instance.start_(name)
            
        end
        
        
        function go(name)
            %% GO to project's folder
            
            
            projman.instance.go_(name)
            
        end
        
        
        function load(name)
            %% LOAD a project i.e., run its startup and load its dependencies
            
            
            projman.instance.load_(name)
            
        end
        
        
        function p = instance()
            %% INSTANCE
            
            
            persistent p_
            
            if isempty(p_)
                p_ = projman();
            end
            
            p = p_;
        end
        
        
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
            f = fullfile(fileparts(which('projman')), sprintf('%s.mat', matlab.lang.makeValidName(chComputername)));
            
        end
        
    end
    
    
    
    %% STATIC PROECTED METHODS
    methods ( Static, Access = protected )
        
        function deps = resolve_dependencies(name)
            %% RESOLVE_DEPENDENCIES resolved dependencies for the given project
            
            
            
            
        end
        
    end
    
    
    
    %% PUBLIC METHODS
    methods ( Access = protected )
        
        function unload_(this, name)
            
        end
        
        
        function start_(this, name)
            
        end
        
        
        function go_(this, name)
            
        end
        
        
        function load_(this, name)
            
        end
        
        
        function p = empty_projects_(this)
            %% EMPTY_PROJECTS_ creates an empty projects structure
            
            
        end
        
    end
    
end

