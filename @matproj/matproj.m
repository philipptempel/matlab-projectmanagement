classdef matproj < handle
    % MATPROJ is a MATLAB project
    
    properties % Public Properties
        Name
        
        ID
        
        Directory
        
        Dependencies = {}
    end % Public Properties
    
    properties ( SetAccess = protected )
        IsNew = false
        
        IsLoaded = false;
    end % ( SetAccess = protected )
    
    properties ( Dependent )
        HasStartup
        
        HasFinish
        
        HasDependencies
    end % ( Dependent )
    
    methods % GENERAL METHODS
        
        function this = matproj(directory, varargin)
            % MATPROJ creates a new matlab project at the specified path
            % 
            % MATPROJ(DIRECTORY) creates a new project at the given directory.
            % The project name will be guessed automatically from the final
            % project directory
            %
            % MATPROJ(DIRECTORY, NAME) names the projet NAME.
            %
            % MATPROJ(DIRECTORY, NAME, DEPENDENCIES) also adds dependencies
            % given as cell array to the project
            
            persistent ip
            
            if isempty(ip)
                ip = inputParser;
                ip.CaseSensitive = false;
                ip.KeepUnmatched = false;
                ip.FunctionName = 'matproj';
                
                ip.addRequired('Directory', @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Directory'));
                ip.addOptional('Name', '', @(x) validateattributes(x, {'char'}, {'nonempty'}, mfilename, 'Name'));
                ip.addOptional('Dependencies', {}, @(x) validateattributes(x, {'cell'}, {'nonempty', 'vector', 'row'}, mfilename, 'Dependencies'));
                
                try
                    args = [{directory}, varargin];
                    ip.parse(args{:});
                catch me
                    throwAsCaller(me);
                end
            end
            
            % Assign the director path
            this.Directory = ip.Results.Directory;
            
            % If the name was given, assign it
            if ~isempty(ip.Results.Name)
                this.Name = ip.Results.Name;
            % No name for project given so it will be inferred from the
            % project's directory name
            else
                this.Name = last(strsplit(directory, filesep));
            end
            
            % Dependencies given?
            if ~isempty(ip.Results.Dependencies)
                this.Dependencies = ip.Results.Dependencies;
            end
            
            % If this is a new project we will set the ID
            if this.IsNew || isempty(this.ID)
                this.ID = char(java.util.UUID.randomUUID);
                
                this.IsNew = false;
            end
        end
        
        function flag = dependsOn(this, that)
            % DEPENDSON determines if this project depends on that project
            % 
            % DEPENDSON(PROJECT) checks if this project depends on the other
            % project PROJECT.
            
            try
                validateattributes(that, {'char', 'matproj'}, {'nonempty'}, mfilename, 'that');
            catch me
                throwAsCaller(me);
            end
            
            % If the project given is a MATPROJ class, then get the ID
            if isa(that, 'matproj')
                that = that.ID;
            end
            
            % Check if the given ID can be found in the dependencies
            flag = any(strcmp(that, this.Dependencies));
        end
        
    end % GENERAL METHODS
    
    methods % SETTERS
        
        function set.Dependencies(this, dependencies)
            try
                validateattributes(dependencies, {'cell'}, {'nonempty', 'vector', 'row'}, mfilename, 'dependencies');
            catch me
                throwAsCaller(me);
            end
            
            this.Dependencies = dependencies;
        end
        
        function set.Directory(this, directory)
            try
                validateattributes(directory, {'char'}, {'nonempty'}, mfilename, 'directory');
                assert(7 == exist(directory, 'dir'), 'PHILIPPTEMPEL:PROJMAN:MATPROJ:SET.DIRECTORY:InvalidDirectory', 'Invalid directory %s given. Does it exist?', directory);
            catch me
                throwAsCaller(me);
            end
            
            this.Directory = directory;
        end
        
        function set.Name(this, name)
            try
                validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'name');
            catch me
                throwAsCaller(me);
            end
            
            this.Name = name;
        end
        
    end % SETTERS
    
    methods % DEPENDENT
        
        function flag = get.HasDependencies(this)
            flag = numel(this.Dependencies) ~= 0;
        end
        
        function flag = get.HasFinish(this)
            flag = 2 == exist(fullfile(this.Directory, 'finish.m'), 'file');
        end
        
        function flag = get.HasStartup(this)
            flag = 2 == exist(fullfile(this.Directory, 'startup.m'), 'file');
        end
        
    end % DEPENDENT
    
    methods % OVERRIDERS
        
        function startup(this)
            % STARTUP starts this project
            
            % Continue only if not loaded
%             if ~this.IsLoaded
                % If there is a statup script
                if this.HasStartup
                    % Run the startup in a save environment
                    try
                        run(fullfile(this, 'startup.m'));
                    catch me
                        throwAsCaller(me);
                    end
                end
                
                % And mark as loaded
                this.IsLoaded = true;
%             end
        end
        
        function finish(this)
            % FINISH finishes this project
            
            % Continue only if loaded
%             if this.IsLoaded
                % If there is a finish script
                if this.HasFinish
                    % Run it in a save environment
                    try
                        run(fullfile(this, 'finish.m'));
                    catch me
                        throwAsCaller(me);
                    end
                end
                
                % Unload the project
                this.IsLoaded = false;
%             end
        end
        
        function f = fullfile(this, varargin)
            % FULLFILE returns the fullfile to a file of this project
            
            f = fullfile(this.Directory, varargin{:});
        end
        
        function cd(this)
            % CD changes to this project
            
            cd(this.Directory);
        end
        
    end % OVERRIDERS
    
end

