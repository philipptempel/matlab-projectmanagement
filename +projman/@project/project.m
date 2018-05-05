classdef (InferiorClasses = {?matlab.graphics.axis.Axes}) project < handle & matlab.mixin.Heterogeneous
    % PROJECT is a single projman project object
    
    
    %% PUBLIC PROPERTIES
    properties
        
        % Human readable name of the project
        Name
        
        % Path of the project's location
        Path
        
        % Array of direct dependencies of the project as projman.project
        Dependencies@projman.project = projman.project.empty(1, 0)
        
        % Array of dependent projects of this project
        Dependents@projman.project = projman.project.empty(1, 0)
        
    end
    
    
    
    %% WRITE-PROTECTED METHODS
    properties ( SetAccess = protected )
        
%         % Files open in the editor when closing the project
%         EditorFiles
        
    end
    
    
    %% DEPENDENT PUBLIC PROPERTIES
    properties ( Dependent )
        
        % Get all open editor files that belong to this project
        Documents
        
        % Structure of the project's configuration
        Config
        
        % Flag if project exists i.e., path exists
        Exists
        
        % Flag if project is activated or not
        IsLoaded
        
        % Number of project dependencies
        NDependencies
        
        % Flag if there are dependencies
        HasDependencies
        
        % Number of dependent projects
        NDependents
        
        % Flag if there are dependent projects
        HasDependents
        
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
        
        % Path to the `projpath.m` file
        PathdefPath
        
        % Flag if project has `projpath.m` function or not
        HasPathdef
        
        % Path to the `documents.mat` file
        DocumentsPath
        
        % Flag if projet has `documents.mat` file or not
        HasDocuments
        
    end
    
    
    %% PROTECTED METHODS
    properties ( Access = protected )
        
        % Original working directory before this project was activated
        OriginalWD
        
        % Flag if this project has been activated using the `load` method
        IsLoaded_ = false
        
    end
    
    
    
    %% GENERAL METHODS
    methods
        
        function this = project(p, name, deps)
            %% PROJECT creates a new project object from a path
            %
            %   PROJECT(PATH) creates a project object at the given path. The
            %   project name will be infered from the name of the last directory
            %   on the path
            %
            %   PROJECT(PATH, NAME) sets the name of the project to NAME.
            %
            %   PROJECT(PATH, NAME, DEPS) creates a project with the 1xK array
            %   of projman.project objects that this project depends on.
            %
            %   P = PROJECT(...) returns the newly created project object
            %
            %   Inputs:
            %
            %   P                   Path to the location of the project
            %
            %   NAME                Name of the project. If left empty, the name
            %                       will be infered from the name of the
            %                       project's last directory
            %
            %   DEPS                1xK projman.project array representing the
            %                       dependencies of this project.
            %
            %   Outputs:
            %
            %   P                   Projman.project object
            
            
            try
                % P = PROJECT(PATH)
                % P = PROJECT(PATH, NAME)
                % P = PROJECT(PATH, NAME, DEPS)
                narginchk(1, 3);
                
                % PROJECT(...)
                % P = PROJECT(...)
                nargoutchk(0, 1);
                
                % Validate path
                validateattributes(p, {'char'}, {'nonempty'}, mfilename, 'Path');
                
                % Check name, if given
                if nargin > 1 && ~isempty(name)
                    validateattributes(name, {'char'}, {'nonempty'}, mfilename, 'Name');
                end
                
                % Check dependencies, if given
                if nargin > 2 && ~isempty(deps)
                    validateattributes(deps, {'projman.project'}, {'nonempty'}, mfilename, 'Dependencies');
                end
            catch me
                throwAsCaller(me);
            end
            
            % Set path
            this.Path = p;
            
            % If name given
            if nargin > 1 && ~isempty(name)
                this.Name = name;
            % No name given, get it from the project's path's last folder's name
            else
                [~, this.Name, ~] = fileparts(this.Path);
            end
            
            % If dependencies given
            if nargin > 2 && ~isempty(deps)
                this.Dependencies = deps;
            end
            
        end
        
    end
    
    
    
    %% PROJECT HANDLING METHODS
    methods
        
        function startup(this)
            %% STARTUP executes the project's startup script/function
            %
            %   STARTUP(P) runs the project's startup script/function.
            
            
            % Only do something if there is a `finish.m` script/function
            if this.HasStartup
                try
                    % Run in the project's root dir
                    this.run_in_projectdir(@startup);
                catch me
                    throwAsCaller(me);
                end
            end
            
        end
        
        
        function finish(this)
            %% FINISH executes the project's `finish` script/function
            %
            %   FINISH(P) runs the project's `finish` script/function 
            
            
            % Only do something if there is a `finish.m` script/function
            if this.HasFinish
                try
                    % Run in the project's root dir
                    this.run_in_projectdir(@finish);
                catch me
                    throwAsCaller(me);
                end
            end
            
        end
        
        
        function reset(this)
            %% RESET resets the project i.e., runs its finish and startup script
            
            
            try
                % Finish the project
                this.finish();
                
                % Then start it
                this.startup();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function open(this)
            %% OPEN a project
            %
            %   OPEN(P) opens the project by adding all its dependencies to the
            %   MATLAB search path, adding this project's paths defintion to the
            %   MATLAB search path, and executing the startup script of the
            %   project
            %
            %   See also
            
            
            % Add to path; run startup; change to directory
            try
                % Add this project to MATLAB search path
                this.addpath();
                
                % Startup this project
                this.startup()
                
                % Load the documents into editor
                this.load_documents();
                
                % Change to the project
                this.cd();
            catch me
                throwAsCaller(me);
            end
        end
        
        
        function close(this)
            %% CLOSE a project
            %
            %   CLOSE(P) closes the project by removing its defined paths from
            %   the MATLAB search path and running the finish script
            %
            %   See also
            
            
            % Run finish.m; remove from path; change to original working
            % directory
            try
                % Finish this project
                this.finish()
                
                % Remove this project from MATLAB search path
                this.rmpath();
                
                % Save list of open documents
                this.save_documents();
                
                % And change back to the previous working directory
                cd(this.OriginalWD);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function p = pathdef(this)
            %% PATHDEF gets this projects `projpath()` result
            
            
            try
                % Get current working directory
                chCWD = pwd;
                
                % Change to the directory of the project
                cd(this.Path);
                
                % Make a cleanup object to return to our old working directory
                % once this function is done
                coCleaner = onCleanup(@() cd(chCWD));
                
                % Run the pathdef file
                p = projpath();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function p = projpath(this)
            %% PROJPATH is a wrapper for PATHDEF
            %
            %   See also:
            %
            %   PROJMAN.PROJECT.PATHDEF
            
            
            p = this.pathdef();
            
        end
        
        
        function v = config(this, prop, default)
            %% CONFIG gets a config value of the given project
            
            
            % By default return the whole config structure
            if nargin < 2
                v = this.Config;
                
                return
            end
            
            % Default 'default' value
            if nargin < 3 || isempty(default)
                default = [];
            end
            
            % If the requested property exists
            if isfield(this.Config, prop)
                % We will get its value to return it to the user
                v = this.Config.(prop);
            % Requested property/field does not exist, so return the default
            % value
            else
                v = default;
            end
            
        end
        
        
%         function add_paths(this, varargin)
%             %% ADD_PATHS adds the given paths to the MATLAB path
%             %
%             %   ADD_PATHS({P1, P2, P3}) adds the given paths to MATLAB path
%             %
%             %   ADD_PATHS(P1, P2, ...) adds the given paths to MATLAB path
%             
%             
%             % Loop over every given path arg
%             for iArg = 1:numel(varargin)
%                 % Get the path
%                 p = varargin{iArg};
%             
%                 % Split path chars like 'p1:p2:p3' into {p1, p2, p3}
%                 if ~iscell(p)
%                     p = regexp(p, pathsep, 'split');
%                 end
% 
%                 % Cell array of added paths
%                 ceAdded = cell(1, 0);
% 
%                 % Loop over every given path
%                 try
%                     for iP = 1:numel(p)
%                         % Add to path
%                         addpath(p{iP})
%                         % Store as added to path
%                         ceAdded = horzcat(ceAdded, p{iP});
%                     end
%                 catch me
%                     % Trigger warning
%                     warning(me.identifier, '%s', me.message);
%                     % And remove all already added paths
%                     this.rem_paths(ceAdded{:});
%                 end
%             end
%         end
        
        
%         function rem_paths(this, varargin)
%             %% REM_PATHS removes the given paths from the MATLAB path
%             %
%             %   REM_PATHS({P1, P2, P3}) removes the given paths from MATLAB path
%             %
%             %   REM_PATHS(P1, P2, ...) removes the given paths from MATLAB path
%             
%             
%             % Set the 'MATLAB:rmpath:DirNotFound' warning to off
%             this.warningstate('off');
%             
%             % Loop over every given path arg
%             for iArg = 1:numel(varargin)
%                 % Get the path
%                 p = varargin{iArg};
%             
%                 % Split path chars like 'p1:p2:p3' into {p1, p2, p3}
%                 if ~iscell(p)
%                     p = regexp(p, pathsep, 'split');
%                 end
% 
%                 % Cell array of added paths
%                 ceRemoved = cell(1, 0);
% 
%                 % Loop over every given path
%                 try
%                     for iP = 1:numel(p)
%                         % Remove from path
%                         rmpath(p{iP});
%                         % Store as added to path
%                         ceRemoved = horzcat(ceRemoved, p{iP});
%                     end
%                 catch me
%                     % Trigger warning
%                     warning(me.identifier, '%s', me.message);
%                 end
%             end
%             
%             % And reset the 'MATLAB:rmpath:DirNotFound' warning's state
%             this.warningstate('on');
%             
%         end

    end
    
    
    
    %% DEPENDENCIES RELATED METHODS
    methods
        
        function deps = merge_dependencies(this)
            %% MERGE_DEPENDENCIES merges dependencies of this project with its dependencies
            
            
            % Get all direct dependencies
            deps = this.Dependencies;

            % Loop over each dependent project and get its dependencies
            for iDep = 1:this.NDependencies
                deps = union(deps, this.Dependencies(iDep).merge_dependencies());
            end
            
        end
        
        
        function deps = resolve_dependencies(this)
            %% RESOLVE_DEPENDENCIES resolves the dependecies of this project
            
            
            % Get all project dependencies
            projs = horzcat(this, this.merge_dependencies());
            projs = fliplr(projs);

            % Build the adjacency matrix
            aAdjacency = this.adjacency(projs);

            % Traverse the graph from the current project to get to the end of
            % the dependencies
            [~, ~, ord] = graphtraverse(sparse(aAdjacency), numel(projs));

            % And return the result as the ordered list of projects going from
            % most dependent to least dependent
            deps = projs(ord);

            % Lastly we should remove this object from the list of dependencies
            % again as we are no dependecy of ourselves
            deps(deps == this) = [];
            
        end
        
        
        function flag = is_dependent_on(this, that, level)
            %% IS_DEPENDENT_ON checks if THIS is dependent on THAT
            
            
            % Validate correct number of arguments
            try
                % THIS.IS_DEPENDENT_ON(THAT)
                % THIS.IS_DEPENDENT_ON(THAT, LEVEL)
                narginchk(2, 3);
                
                % THIS.IS_DEPENDENT_ON(...)
                % F = THIS.IS_DEPENDENT_ON(...)
                nargoutchk(0, 1);
                
                % Check correct number of `this` and `that` are given. We only
                % support comparing one-to-many or many-to-one finding the
                % match, or compare many-to-many on a basis of one-to-one
                assert(numel(this) == numel(that) || numel(this) == 1 && numel(that) > 1 || numel(that) == 1 && numel(this) > 1, 'Matrix dimensions must agree');
            catch me
                throwAsCaller(me);
            end
            
            % Level of checking for dependency
            if nargin < 3 || isempty(level)
                level = 'flat';
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
                    switch lower(level)
                        % Flat dependency checking: Only first level of
                        % dependencies
                        case 'flat'
                            if this(iThis).Dependencies(iDep) == that(iThis) ...
                                && this(iThis) ~= that(iThis)
                                % Then we depend on it
                                flag(iThis) = 1;
                                % and break the loop
                                break
                            end
                        case 'deep'
                            if ( this(iThis).Dependencies(iDep) == that(iThis) ...
                                || this(iThis).Dependencies(iDep).is_dependent_on(that(iThis), 'deep') ) ...
                                && this(iThis) ~= that(iThis)
                                % Then we depend on it
                                flag(iThis) = 1;
                                % and break the loop
                                break
                            end
                    end
                end
            end
            
        end
        
        
        function flag = is_dependency_of(this, that, level)
            %% IS_DEPENDENCY_OF checks if THIS is a dependency of THAT
            
            
            % Validate correct number of arguments
            try
                % THIS.IS_DEPENDENCY_OF(THAT)
                % THIS.IS_DEPENDENCY_OF(THAT, LEVEL)
                narginchk(2, 3);
                
                % THIS.IS_DEPENDENCY_OF(...)
                % F = THIS.IS_DEPENDENCY_OF(...)
                nargoutchk(0, 1);
                
                % Check correct number of `this` and `that` are given. We only
                % support comparing one-to-many or many-to-one finding the
                % match, or compare many-to-many on a basis of one-to-one
                assert(numel(this) == numel(that) || numel(this) == 1 && numel(that) > 1 || numel(that) == 1 && numel(this) > 1, 'Matrix dimensions must agree');
            catch me
                throwAsCaller(me);
            end
            
            % Level of checking for dependency
            if nargin < 3 || isempty(level)
                level = 'flat';
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
                    switch lower(level)
                        % Flat dependency checking: Only first level of
                        % dependencies
                        case 'flat'
                            if this(iThis).Dependents(iDep) == that(iThis) ...
                                && this(iThis) ~= that(iThis)
                                % Then we are dependent on it
                                flag(iThis) = 1;
                                % and break the loop
                                break
                            end
                        % Deep dependency checking: All levels of dependencies
                        case 'deep'
                            if ( this(iThis).Dependents(iDep) == that(iThis) ...
                                || this(iThis).Dependents(iDep).is_dependency_of(that(iThis), 'deep') ) ...
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
        
    end
    
    
    
    %% AXES OVERRIDERS
    methods
        
        function varargout = plot(this, varargin)
            %% PLOT the dependencies and dependents of this project
            
            
            % Collect all arguments
            args = [{this}, varargin];
            
            % Split the arguments
            [this, ax, args] = projman.project.splitargs(args{:});
            
            % Get the correct plot axes
            ax = newplot(ax);
            
            % Turn this object into a digraph
            G = this.digraph();
            
            % Plot the graph
            h = plot(ax ...
                , G ...
                , 'LineWidth', 2 ...
                , 'Layout', 'layered' ...
                , args{:} ...
            );
            
            % Assign output quantities
            if nargout > 0
                varargout{1} = h;
            end
            
        end
        
    end
    
    
    
    %% OVERRIDERS
    methods
        
        function od = cd(this)
            %% CD to this project's path
            
            
            % Get old folder
            this.OriginalWD = pwd;
            
            % Assign output?
            if nargout > 0
                od = this.OriginalWD;
            end
            
            % To avoid weird behavior, try to change the WD
            try
                cd(this.Path);
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function op = addpath(this)
            %% ADDPATH adds this project to the MATLAB path
            %
            %   ADDPATH(P) adds this project as well as all its dependencies to
            %   the MATLAB search path
            
            
            % First, get all dependencies in the correct order
            deps = this.resolve_dependencies();
            
            % Get the current working directory
            chOldWD = pwd;
            
            % Assign output as the currently defined MATLAB search path
            if nargout > 0
                op = path();
            end
            
            % Startup deps, startup this project, then go to project's path
            try
                % Add each depedency to the path
                for iDep = 1:numel(deps)
                    deps(iDep).addpath();
                end
                
                % Get the path definiton for the project
                p = this.pathdef();
                
                % Got path definition?
                if ~isempty(p)
                    % Then add it to MATLAB search path
                    addpath(p{:});
                end
                
                % Mark this project as activated since all path definitions have
                % been added
                this.IsLoaded_ = true;
            catch me
                % Change back to the original working directory
                cd(chOldWD);
                
                % And raise the original exception
                throwAsCaller(me);
            end
            
        end
        
        
        function rmpath(this, all)
            %% RMPATH removes this project from MATLAB search path
            %
            %   RMPATH(P) removes the paths defined in P.PATHDEF from the MATLAB
            %   search path
            %
            %   RMPATH(P, ALL) removes the paths of all dependencies, too, if
            %   ALL is equal to any of 'on', 'yes', 1, or true.
            
            
            % Default arguments
            if nargin < 2 || isempty(all)
                all = false;
            end
            
            % Convert any 'on', or 'yes' to logical values
            if isa(all, 'char')
                all = any(strcmpi({'on', 'yes'}, all));
            end
            
            % First, remove this project from MATLAB search path
            p = this.pathdef();
            if ~isempty(p)
                rmpath(p{:})
            end
            
            % And project is no longer activated because it's been removed from
            % the MATLAB search path
            this.IsLoaded_ = false;
            
            % Remove paths of dependencies, too?
            if all
                % First, get all dependencies in the correct order
                deps = this.resolve_dependencies();
                
                % Loop over each dependency
                for iDep = 1:numel(deps)
                    % And remove this dependency
                    deps(iDep).rmpath('on');
                end
            end
            
        end
        
        
        function flag = exist(this)
            %% EXIST overrides EXIST(PROJMAN.PROJECT)
            
            
            flag = this.Exists;
            
        end
        
        
        function flag = isequal(this, that)
            %% ISEQUAL compares THIS and THAT to be the same project
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
        end
        
        
        function flag = isequaln(this, that)
            %% ISEQUALN compares THIS and THAT to be the same project
            
            
            flag = strcmpi({this.Path}, {that.Path});
            
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
            %
            %   THIS <= THAT is true if THIS is a dependent of THAT or if THAT is
            %   a dependency of THAT - or else if THIS and THAT are the same
            %   project i.e, their paths are the same
            
            
            te = this.is_dependent_on(that) || this == that;
            
        end
        
        
        function te = ge(this, that)
            %% GE compares if THIS is greater than or equal to THAT
            %
            %   THIS >= THAT is true if THIS is a dependency of THAT or if THAT
            %   is a dependent of THAT - or else if THIS and THAT are the same
            %   project i.e, their paths are the same
            
            
            te = this.is_dependency_of(that) || this == that;
            
        end
        
        
        function te = lt(this, that)
            %% LT compares if THIS is less than THAT i.e., THIS is dependent on THAT
            %
            %   THIS < THAT is true if THIS is a dependent of THAT or if THAT is
            %   a dependency of THAT.
            
            
            te = this.is_dependent_on(that);
            
        end
        
        
        function te = gt(this, that)
            %% GT compares if THIS is greater than THAT i.e., THIS depends on THAT
            %
            %   THIS >  THAT is true if THIS is a dependent of THAT or if THAT is
            %   a dependency of THAT.
            
            
            te = this.is_dependency_of(that);
            
        end
        
        
        function c = char(this)
            %% CHAR converts this object to a char
            
            
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
            function chdeps = chardeps(o)
                % If there are dependencies, get all their names
                if o.HasDependencies
                    cedeps = arrayfun(@(d) char(d.Name), fliplr(o.resolve_dependencies()), 'UniformOutput', false);
                % No dependencies, no names
                else
                    cedeps = {};
                end
                
                % Turn cell into a char
                chdeps = strjoin(cedeps, ', ');
            end
            
            % Loop over all dependencies and get their names
            t.Dependencies = arrayfun(@(t) chardeps(t), this, 'UniformOutput', false).';
            
        end
        
        
        function dg = digraph(this)
            %% DIGRAPH turns the project and its dependencies into a directed graph
            
            
            % Resolve project dependencies
            deps = union(this.resolve_dependencies(), this);

            % Get the adjacency matrix
            A = this.adjacency(deps);

            % Create the directed graph object
            dg = digraph(A, {deps.Name});
            
        end
        
        
        function p = path(this)
            %% PATH returns this project's base path
            
            
            p = this.Path;
            
        end
        
        
        function f = fullfile(this, varargin)
            %% FULLFILE returns the file pathed relative to this project
            
            
            f = fullfile(this.Path, varargin{:});
            
        end
        
    end
    
    
    
    %% SETTERS
    methods
        
        function set.Dependencies(this, deps)
            %% SET.DEPENDENCIES sets the dependencies
            
            
            % Validate arguments
            try
                validateattributes(deps, {'projman.project'}, {}, mfilename, 'deps');
            catch me
                throwAsCaller(me);
            end
            
            % Loop over each object and tell it that we are dependent on it
            for iDep = 1:numel(deps)
                deps(iDep).Dependents = horzcat(deps(iDep).Dependents, this);
            end
            
            % Set the dependencies
            this.Dependencies = deps;
            
        end
        
        
        function set.Config(this, c)
            %% SET.CONFIG sets the config for this object
            
            
            % Validate arguments
            try
                validateattributes(c, {'struct'}, {}, mfilename, 'Config');
            catch me
                throwAsCaller(me);
            end
            
            % And save the config to the file
            save(this.ConfigPath, '-struct', 'c'); %#ok<MCSUP>
            
        end
        
        
        function set.Documents(this, ef)
            %% SET.DOCUMENTS sets the previous session's editor files of this object i.e., opens them in the editor
            
            
            % If there are files
            if ~isempty(ef)
                % Loop over every file
                for iFile = 1:size(ef, 1)
                    % Open the file in the editor
                    d = matlab.desktop.editor.openDocument(ef.Filename(iFile,1:end));
                    % and place the cursor at the right spot
                    d.goToPositionInLine(ef.Selection(iFile,1), ef.Selection(iFile,3));
                end
            end
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function flag = get.IsLoaded(this)
            %% GET.ISLOADED flags if this project is loaded i.e., all paths added to the MATLAB search path
            
            
            % Flag for the project's paths on the MATLAB search path
            flag_ = true;
            
            % Get all defined paths
            p = this.pathdef();
            
            % Get the current MATLAB search path
            path_ = path;
            
            % If the project is loaded and project specific paths have been
            % defined we need to
            if ~isempty(p)
                % Break the path down into single paths
                p = cellfun(@(pp) strsplit(pp, pathsep), p, 'UniformOutput', false);
                % Flatten the cell
                horzcat(p{:});
                % And remove empty ones (there's at least one empty one because
                % MATLAB appends PATHSEP to a string whenever one is using
                % GENPATH i.e., the last character of any string from GENPATH
                % ends with PATHSEP
                p(cellfun(@isempty, p)) = [];
                
                % Loop over every project path path and check if it is in the
                % MATLAB search path or not
                for iP = 1:numel(p)
                    % Check if the path is in the MATLAB path
                    if ~contains(path_, [p{iP}, pathsep])
                        % Given path is not on here
                        flag_ = false;
                        % We only need to check until we find a path that's not
                        % on PATH so we can break here
                        break
                    end
                end
            end
            
            % If all of the project's paths are on the MATLAB search path, then
            % the project is per definition loaded, so we should make our own
            % internal loaded flag aware of that
            if flag_
                % Update the internal loaded flag
                this.IsLoaded_ = flag_;
            end
            
            % Assign output quantity
            flag = this.IsLoaded_ && flag_;
            
        end
        
        
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
        
        
        function flag = get.HasDependencies(this)
            %% GET.HASDEPENDENCIES flags if there are dependenies defined on this object
            
            
            flag = 0 ~= this.NDependencies;
            
        end
        
        
        function flag = get.HasDependents(this)
            %% GET.HASDEPENDENTS flags if there are dependent projects defined on this object
            
            
            flag = 0 ~= this.NDependents;
            
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
        
        
        function c = get.Config(this)
            %% GET.CONFIG gets the project's config
            
            
            % If there is a config file...
            if this.HasConfig
                % Load it
                c = load(this.ConfigPath);
            % No config file in the project's folder
            else
                % So default to an empty structure
                c = struct();
            end
            
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
            
            
            p = fullfile(this.Path, 'projpath.m');
            
        end
        
        
        function flag = get.HasPathdef(this)
            %% GET.HASPATHDEF checks if the project has a `pathdef.m` function or not
            
            
            flag = 2 == exist(this.PathdefPath, 'file');
            
        end
        
        
        function e = get.DocumentsPath(this)
            %% GET.DOCUMENTSPATH gets the path to the `documents.mat` file
            
            
            e = fullfile(this.Path, 'documents.mat');
            
        end
        
        
        function flag = get.HasDocuments(this)
            %% GET.HASDOCUMENTS checks if the project has a `documents.mat` file or not
            
            
            flag = 2 == exist(this.DocumentsPath, 'file');
            
        end
        
        
        function ef = get.Documents(this)
            %% GET.DOCUMENTS gets all open editor files of this project
            
            
            % Get all open files
            ceFiles = matlab.desktop.editor.getAll();
            
            % Now file the files such that we only have ones that are actually
            % from within this project's root folder
            ef = ceFiles(startsWith({ceFiles.Filename}, this.Path) & [ceFiles.Opened]);
            
        end
        
    end
    
    
    
    %% STATIC PROTECTED METHOD
    methods ( Static, Access = protected )
        
        function [this, ax, args] = splitargs(this, varargin)
            %% SPLITARGS splits arguments given to axes plot functions
            
            
            args = [{this}, varargin];
            [ax, args, ~] = axescheck(args{:});
            this = args{1};
            args = args(2:end);
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        function A = adjacency(this, projs)
            %% ADJACENCY builds the adjacency matrix of dependencies for the given projects
            
            
            % Now we need to properly resolve the dependencies
            A = zeros(numel(projs), numel(projs));
            
            % Loop over every project
            for iP = 1:numel(projs)
                % Mark all the dependencies of the current project with the
                % others in the adjacency matrix
                A(iP,:) = projs(iP) < projs;
%                 A(:,iP) = projs(iP).is_dependency_of(projs);
            end
            
        end
        
        
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
        
        
        function varargout = run_in_projectdir(this, fh)
            %% RUN_IN_PROJECT runs the given command in the project's directory
            %
            %   RUN_IN_PROJECT(P, FH) runs the function defined through handle
            %   FH in the project's root directory by changing the current
            %   working directory to P.PATH, running FH, and then changing back
            %   to the original working directory
            
            
            try
                % Get the current working directory
                chCWD = pwd;

                % Make a cleanup object to return to our old working directory
                % once this function is done
                coCleaner = onCleanup(@() cd(chCWD));

                % Change to the project
                this.cd();

                % And run the command
                if nargout == 0
                    fh();
                elseif nargout == 1
                    varargout{1} = fh();
                elseif nargout == 2
                    [varargout{1}, varargout{2}] = fh();
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function save_documents(this)
            %% SAVE_DOCUMENTS saves the list of open project files in the MATLAB EDITOR
            
            
            % Get the open editor files of this project
            ef = this.Documents;

            % Store the documents in a file for later use
            if ~isempty(ef)
                % Cleanup the ef array (it contains some fields that cannot be
                % serialized)
                ef = table(vertcat(ef.Filename), vertcat(ef.Selection), 'VariableNames', {'Filename', 'Selection'});
                
                % Save to MAT file
                save(this.DocumentsPath, 'ef');
            % No currently open documents, so make sure the `documents.mat`
            % file doesn't accidentally exist
            else
                % If the documents file exists
                if this.HasDocuments
                    % Try to delete the file
                    try
                        delete(this.DocumentsPath);
                    catch me
                        warning(me.identifier, '%s', me.message);
                    end
                end
            end

            % Free some memory
            clear('ef');

        end
        
        
        function load_documents(this)
            %% LOAD_DOCUMENTS loads the list of open project files in the MATLAB editor
            
            
            
            % Load the projects
            try
                % Create a matfile object
                moFile = matfile(this.DocumentsPath);
                
                % Get the variables inside the matfile
                stVariables = whos(moFile);
                
                % If there are variables, we will get them
                if numel(stVariables)
                    % Find the first variable being of type 'cell'
                    [~, idx] = find(strcmp({stVariables.name}, 'ef') & strcmp({stVariables.class}, 'table'), 1, 'first');
                    
                    % Get the document names and we're done
                    this.Documents = moFile.(stVariables(idx).name);
                end
            catch me
                % Init empty documents array
                this.Documents = cell(1, 0);
            end
        end
        
    end
    
    
end
