classdef project < handle & matlab.mixin.Heterogeneous
    % PROJECT is a single projman project object
    
    
    %% PUBLIC PROPERTIES
    properties
        
        % Human readable name of the project
        Name
        
        % Path of the project's location
        Path
        
        % Array of direct dependencies of the project as projman.project
        Dependencies
        
        % Array of dependent projects of this project
        Dependents
        
        % Project configuration
        Config = struct();
        
    end
    
    
    %% DEPENDENT PUBLIC PROPERTIES
    properties ( Dependent )
        
        % Number of project dependencies
        NDependencies
        
        % Number of dependent projects
        NDependents
        
        % Flag if project exists i.e., path exists
        Exists
        
        % Path to `startup.m` file
        StartupPath
        
        % Flag if project has `startup.m` file or not
        HasStartup
        
        % Path to `finish.m` file
        FinishPath
        
        % Flag if project has `finish.m` file or not
        HasFinish
        
        % Path to the `config.mat` file
        ConfigPath
        
        % Flag if project has `config.mat` file or not
        HasConfig
        
        % Path to the `pathdef.m` file
        PathdefPath
        
        % Flag if project has `pathdef.m` function or not
        HasPathdef
        
    end
    
    
    %% PROTECTED METHODS
    properties ( Access = protected )
        
        % Original working directory before this project was activated
        OriginalWD
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = project(p, varargin)
            %% PROJECT creates a new project object from a path
            
            
            try
                % P = PROJECT(PATH)
                % P = PROJECT(PATH, NAME)
                % P = PROJECT(PATH, NAME, DEPS)
                narginchk(1, 3);
                
                % PROJECT(...)
                % P = PROJECT(...)
                nargoutchk(0, 1);
                
                % Validate arguments
                validateattributes(p, {'char'}, {'nonempty'}, mfilename, 'Path');
                
                % Check name, if given
                if nargin > 1 && ~isempty(varargin{1})
                    validateattributes(varargin{1}, {'char'}, {'nonempty'}, mfilename, 'Name');
                end
                
                % Check dependencies, if given
                if nargin > 2 && ~isempty(varargin{2})
                    validateattributes(varargin{2}, {'projman.project'}, {'nonempty'}, mfilename, 'Dependencies');
                end
            catch me
                throwAsCaller(me);
            end
            
            % Set path
            this.Path = p;
            
            % If name given
            if nargin > 1 && ~isempty(varargin{1})
                this.Name = varargin{1};
            % No name given, get it from the project's path's last folder's name
            else
                [~, this.Name, ~] = fileparts(this.Path);
            end
            
            % If dependencies given
            if nargin > 2 && ~isempty(varargin{2})
                this.Dependencies = varargin{2};
            end
            
            % Load the config file
            this.loadconf();
            
        end
        
        
        function deps = resolve_dependencies(this)
            %% RESOLVE_DEPENDENCIES resolves the dependecies of this project
            
            
            % Get all dependent projects
            projs = this.Dependencies;
            
            % Loop over each dependent project and get its dependencies
            for iDep = 1:this.NDependencies
                projs = horzcat(projs, this.Dependencies(iDep).resolve_dependencies());
            end
            
            % Now we need to properly resolve the dependencies
            
            
            % And return the result
            deps = projs;
            
        end
        
        
        function go(this)
            %% GO goes to this projects directory
            
            
            try
                cd(this.Path);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function activate(this)
            %% ACTIVATE this project and all its dependencies i.e., run all `startup.m` scripts/functions of dependencies and project itself
            
            
            % Get the original i.e., pre-activate working directory if it's
            % different to the project's directory
            if ~strcmp(pwd, this.Path)
                this.OriginalWD = pwd;
            end
            
            % First, get all dependencies in the correct order
            deps = this.resolve_dependencies();
            
            % Startup deps, load pathdef, then go to project
            try
                % Startup each dependency
                for iDep = 1:numel(deps)
                    deps(iDep).startup();
                end
                
                % Startup this project
                this.startup()
                
                % Lastly, go to this project
                this.go();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function deactivate(this)
            %% DEACTIVATE this projet and its dependencies i.e., run all `finish.m` scripts/functions of dependencies and project itself
            
            
            try
                % Finis the project through its finish script
                this.finish();
                
                if ~isempty(this.OriginalWD)
                    % Change to the original i.e., pre-activation working
                    % directory
                    cd(this.OriginalWD)
                    % And reset the original working directory path
                    this.OriginalWD = '';
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function delete(this)
            %% DELETE the object resolves in the project to be deactivated
            
            
            this.deactivate();
            
        end
        
        
        function that = saveobj(this)
            %% SAVEOBJ implements the saveobj methods
            
            
            % Save the config
            this.saveconf();
            
            % Just copy the file
            that = this;
            
        end
        
        
        function saveconf(this)
            %% SAVECONF saves the configuration to the project's folder
            
            
            % Save the config file if there is some
            if ~isempty(fieldnames(this.Config))
                % Get a scalar config struct to be saveable
                conf = this.Config;
                
                % Save the config structure
                save(this.ConfigPath, '-struct', 'conf');
                
                % And remove that temporary structure again
                clear('conf');
            end
            
        end
        
        
        function varargout = loadconf(this)
            %% LOADCONF loads the config file
            
            
            if this.HasConfig
                try
                    % Load the config file
                    this.Config = load(this.ConfigPath);
                catch me
                    throwAsCaller(me);
                end
            end
            
            % Assign output quantities
            if nargout > 0
                varargout{1} = this.Config;
            end
            
        end
        
        
        function startup(this)
            %% STARTUP starts this project i.e., runs its `startup.m` function/script
            
            
            % Has `startup.m` script/function?
            if this.HasStartup
                % Run it
                try
                    run(this.StartupPath)
                catch me
                    throwAsCaller(me);
                end
            end
            
            % Has `pathdef.m` function?
            if this.HasPathdef
                % Add to path
                try
                    this.add_paths(this.pathdef());
                catch me
                    throwAsCaller(me);
                end
            end
            
        end
        
        
        function finish(this)
            %% FINISH finishes this project i.e., runs its `finish.m` function/script
            
            
            if this.HasFinish
                try
                    run(this.FinishPath)
                catch me
                    throwAsCaller(me);
                end
            end
            
        end
        
        
        function p = pathdef(this)
            %% PATHDEF gets this projects `pathdef()` result
            
            
            try
                p = run(this.PathdefPath);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function add_paths(this, varargin)
            %% ADD_PATHS adds the given paths to the MATLAB path
            %
            %   ADD_PATHS({P1, P2, P3}) adds the given paths to MATLAB path
            %
            %   ADD_PATHS(P1, P2, ...) adds the given paths to MATLAB path
            
            
            % Loop over every given path arg
            for iArg = 1:numel(varargin)
                % Get the path
                p = varargin{iArg};
            
                % Split path chars like 'p1:p2:p3' into {p1, p2, p3}
                if ~iscell(p)
                    p = regexp(p, pathsep, 'split');
                end

                % Cell array of added paths
                ceAdded = cell(1, 0);

                % Loop over every given path
                try
                    for iP = 1:numel(p)
                        % Add to path
                        addpath(p)
                        % Store as added to path
                        ceAdded{end+1} = p;
                    end
                catch me
                    % Trigger warning
                    warning(me.identifier, me.message);
                    % And remove all already added paths
                    this.rem_paths(ceAdded{:});
                end
            end
        end
        
        
        function rem_paths(this, varargin)
            %% REM_PATHS removes the given paths from the MATLAB path
            %
            %   REM_PATHS({P1, P2, P3}) removes the given paths from MATLAB path
            %
            %   REM_PATHS(P1, P2, ...) removes the given paths from MATLAB path
            
            
            % Set the 'MATLAB:rmpath:DirNotFound' warning to off
            this.warningstate('off');
            
            % Loop over every given path arg
            for iArg = 1:numel(varargin)
                % Get the path
                p = varargin{iArg};
            
                % Split path chars like 'p1:p2:p3' into {p1, p2, p3}
                if ~iscell(p)
                    p = regexp(p, pathsep, 'split');
                end

                % Cell array of added paths
                ceRemoved = cell(1, 0);

                % Loop over every given path
                try
                    for iP = 1:numel(p)
                        % Remove from path
                        rmpath(p);
                        % Store as added to path
                        ceRemoved{end+1} = p;
                    end
                catch me
                    % Trigger warning
                    warning(me.identifier, me.message);
                    % And remove all already added paths
                    this.add_paths(ceRemoved{:});
                end
            end
            
            % And reset the 'MATLAB:rmpath:DirNotFound' warning's state
            this.warningstate('on');
            
        end
        
        
        function flag = is_dependent_on(this, that)
            %% IS_DEPENDENT_ON checks if THIS is dependent on THAT
            
            
            % Validate correct number of arguments
            try
                assert(numel(this) == numel(that) || numel(this) == 1 && numel(that) > 1 || numel(that) == 1 && numel(this) > 1, 'Matrix dimensions must agree');
            catch me
                throwAsCaller(me);
            end
            
            % Repeat 1x1 sized THIS to match size of THAT
            if numel(this) == 1
                this = repmat(this, size(that));
            end
            
            % Repeat 1x1 sized THAT to match size of THIS
            if numel(that) == 1
                that = repmat(that, size(this));
            end
            
            % Init
            flag = zeros(size(this));
            
            % Loop over each this argument
            for iThis = 1:numel(this)
                % Loop over each dependency
                for iDep = 1:this(iThis).NDependencies
                    % If the current dependency is the other object or if the
                    % current dependency recursively depends on that...
                    if ( this(iThis).Dependencies(iDep) == that(iThis) ...
                        || this(iThis).Dependencies(iDep).is_dependent_on(that(iThis)) ) ...
                        && this(iThis) ~= that(iThis)
                        % Then we depend on it
                        flag(iThis) = 1;
                        % and break the loop
                        break
                    end
                end
            end
            
        end
        
        
        function flag = is_dependency_of(this, that)
            %% IS_DEPENDENCY_OF checks if THIS is a dependency of THAT
            
            
            % Validate correct number of arguments
            try
                assert(numel(this) == numel(that) || numel(this) == 1 && numel(that) > 1 || numel(that) == 1 && numel(this) > 1, 'Matrix dimensions must agree');
            catch me
                throwAsCaller(me);
            end
            
            % Repeat 1x1 sized THIS to match size of THAT
            if numel(this) == 1
                this = repmat(this, size(that));
            end
            
            % Repeat 1x1 sized THAT to match size of THIS
            if numel(that) == 1
                that = repmat(that, size(this));
            end
            
            % Init
            flag = zeros(size(this));
            
            % Loop over each this argument
            for iThis = 1:numel(this)
                % Loop over each dependent object
                for iDep = 1:this(iThis).NDependents
                    % If the current dependency is the other object or if the
                    % current dependency recursively is dependent on that...
                    if ( this(iThis).Dependents(iDep) == that(iThis) ...
                        || this(iThis).Dependents(iDep).is_dependency_of(that(iThis)) ) ...
                        && this(iThis) ~= that(iThis)
                        % Then we are dependent on it
                        flag(iThis) = 1;
                        % and break the loop
                        break
                    end
                end
            end
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function flag = exist(this)
            %% EXIST overrides EXIST(PROJMAN.PROJECT)
            
            
            flag = this.Exists;
            
        end
        
        function flag = eq(this, that)
            %% EQ compares if two PROJECT objects are the same
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function flag = neq(this, that)
            %% NEQ compares if two PROJECT objects are not the same
            
            
            flag = ~strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function te = le(this, that)
            %% LE compares if THIS is less than or equal to THAT
            
            
            te = this.is_dependent_on(that) || this == that;
            
        end
        
        
        function te = ge(this, that)
            %% GE compares if THIS is greater than or equal to THAT
            
            
            te = this.is_dependency_of(that) || this == that;
            
        end
        
        
        function te = lt(this, that)
            %% LT compares if THIS is less than THAT i.e., THIS is dependent on THAT
            
            
            te = this.is_dependent_on(that);
            
        end
        
        
        function te = gt(this, that)
            %% GT compares if THIS is greater than THAT i.e., THIS depends on THAT
            
            
            te = this.is_dependency_of(that);
            
        end
        
        
        function c = char(this)
            %% CHAR convers this object to a char
            
            
            % Allow multiple arguments to be passed
            if numel(this) > 1
                c = {this.Name};
            % Single argument passed, so just get its name
            else
                c = this.Name;
            end
            
        end
        
        
        function t = table(this)
            %% TABLE converts this object to a table
            
            
            % Create a table object
            t = table();
            
            % Set the names
            t.Name = {this.Name}.';
            % Set the paths
            t.Path = {this.Path}.';
            % And set the dependencies
            t.Dependencies = arrayfun(@(ii) char(ii.Dependencies), this, 'UniformOutput', false).';
            
        end
        
    end
    
    
    %% SETTERS
    methods
        
        function set.Dependencies(this, deps)
            %% SET.DEPENDENCIES sets the dependencies
            
            
            % Loop over each object and tell it that we are dependent on it
            for iDep = 1:numel(deps)
                deps(iDep).Dependents = horzcat(deps(iDep).Dependents, this);
            end
            
            % Set the dependencies
            this.Dependencies = deps;
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function flag = get.Exists(this)
            %% GET.EXIST flags if the path exists
            
            
            flag = 7 == exist(this.Path, 'dir');
            
        end
        
        function n = get.NDependencies(this)
            %% GET.NDEPENDENCIES returns the number of direct dependencies of this project
            
            
            n = numel(this.Dependencies);
            
        end
        
        
        function n = get.NDependents(this)
            %% GET.NDEPENDENTS returns the number of directly dependent projects of this project
            
            
            n = numel(this.Dependents);
            
        end
        
        
        function p = get.StartupPath(this)
            %% GET.STARTUP gets the path to the `startup.m` file
            
            
            p = fullfile(this.Path, 'startup.m');
            
        end
        
        
        function flag = get.HasStartup(this)
            %% GET.HASSTARTUP checks if the project has a startup file/function or not
            
            
            flag = 2 == exist(this.StartupPath, 'file');
            
        end
        
        
        function p = get.FinishPath(this)
            %% GET.FINISH gets the path to the `finish.m` file
            
            
            p = fullfile(this.Path, 'finish.m');
            
        end
        
        
        function flag = get.HasFinish(this)
            %% GET.HASFINISH checks if the project has a finish file/function or not
            
            
            flag = 2 == exist(this.FinishPath, 'file');
            
        end
        
        
        function p = get.ConfigPath(this)
            %% GET.CONFIGPATH gets the path to the `config.mat` file
            
            
            p = fullfile(this.Path, 'config.mat');
            
        end
        
        
        function flag = get.HasConfig(this)
            %% GET.HASCONFIG checks if the project has a config file or not
            
            
            flag = 2 == exist(this.ConfigPath, 'file');
            
        end
        
        
        function p = get.PathdefPath(this)
            %% GET.PATHDEFPATH gets the path to the `pathdef.m` function
            
            
            p = fullfile(this.Path, 'pathdef.m');
            
        end
        
        
        function flag = get.HasPathdef(this)
            %% GET.HASPATHDEF checks if the project has a `pathdef.m` function or not
            
            
            flag = 2 == exist(this.ConfigPath, 'file');
            
        end
        
    end
    
    
    
    methods ( Access = protected )
        
        function warningstate(this, state)
            %% WARNINGSTATE
            
            
            persistent prevstate
            
            % Get the initial previous warning state
            if isempty(prevstate)
                stState = warning('query', 'MATLAB:rmpath:DirNotFound');
                prevstate = stState.state;
            end
            
            switch state
                case 'off'
                    % Get the warning's previous state
                    stState = warning('query', 'MATLAB:rmpath:DirNotFound');
                    prevstate = stState.state;
                    
                    % Set the warning state to 'off'
                    warning('off', 'MATLAB:rmpath:DirNotFound');
                    
                case 'on'
                    % Set the new state
                    warning(prevstate, 'MATLAB:rmpath:DirNotFound');
            end
        end
        
    end
    
    
end

