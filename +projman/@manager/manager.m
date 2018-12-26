classdef manager < handle
    % MANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    
    %% PUBLIC PROPERTIES
    properties
        
        % Collection of projects found
        Projects@projman.project = projman.project.empty(1, 0)
        
    end
    
    
    %% WRITE-PROTECTED PROPERTIES
    properties ( SetAccess = protected )
        
    end
    
    
    %% DEPENDENT PUBLIC PROPERTIES
    properties ( Dependent )
        
        % Array of loaded projects
        Loaded
        
    end
    
    
    
    %% STATIC METHODS
    methods ( Static )
        
        
        function addthis(varargin)
            %% ADDTHIS adds the current working directory as new project
            %
            %   ADDTHIS(Name, Value) adds the current working directory as new
            %   project to the project manager instance. All arguments to
            %   ADDTHIS are passed down to PROJMAN.PROJECT.
            %
            %   See also
            %   PROJMAN.PROJECT
            
            
            % Build the arguments to `projman.project`
            varargin = [{pwd}, varargin];
            
            % Build a project
            p = projman.project(varargin{:});
            
            % Get a projects manager instance
            pjm = pm('reset');
            
            % Append project
            pjm.Projects = [pjm.Projects, p];
            
            % And save PJM
            save(pjm);
            
        end
        
    end
    
    
    
    %% STATIC PROTECTED METHODS
    methods ( Static, Access = protected )
        
        function d = strdist(r, b, krk, cas)
            %% STRDIST computes distances between strings
            %
            % d=strdist(r,b,krk,cas) computes Levenshtein and editor distance 
            % between strings r and b with use of Vagner-Fisher algorithm.
            %    Levenshtein distance is the minimal quantity of character
            % substitutions, deletions and insertions for transformation
            % of string r into string b. An editor distance is computed as 
            % Levenshtein distance with substitutions weight of 2.
            % d=strdist(r) computes numel(r);
            % d=strdist(r,b) computes Levenshtein distance between r and b.
            % If b is empty string then d=numel(r);
            % d=strdist(r,b,krk)computes both Levenshtein and an editor distance
            % when krk=2. d=strdist(r,b,krk,cas) computes a distance accordingly 
            % with krk and cas. If cas>0 then case is ignored.
            % 
            % Example.
            %  disp(strdist('matlab'))
            %     6
            %  disp(strdist('matlab','Mathworks'))
            %     7
            %  disp(strdist('matlab','Mathworks',2))
            %     7    11
            %  disp(strdist('matlab','Mathworks',2,1))
            %     6     9

            switch nargin
               case 1
                  d = numel(r);
                  return
               case 2
                  krk = 1;
                  bb = b;
                  rr = r;
               case 3
                   bb = b;
                   rr = r;
               case 4
                  bb = b;
                  rr = r;
                  if cas > 0
                     bb = upper(b);
                     rr = upper(r);
                  end
            end

            if krk ~= 2
               krk = 1;
            end

            d = zeros(1, 0);
            luma = numel(bb);
            lima = numel(rr);
            lu1 = luma + 1;
            li1 = lima + 1;
            dl = zeros([lu1, li1]);
            dl(1,:) = 0:lima;
            dl(:,1) = 0:luma;
            % Distance
            for krk1 = 1:krk
                for ii = 2:lu1
                    bbi = bb(ii-1);
                    for ij = 2:li1
                        kr = krk1;
                        if strcmp(rr(ij-1),bbi)
                            kr = 0;
                        end
                        dl(ii,ij) = min([dl(ii-1,ij-1) + kr, dl(ii-1,ij) + 1, dl(ii,ij-1) + 1]);
                    end
                end
                d = horzcat(d, dl(end,end));
            end
            
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
                % If a project is passed, check if it is a registered project
                if isa(name, 'projman.project')
                    assert(any(this.Projects == name), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project object given is not a registered project.');
                    
                    p = name;
                % Name of project passed as char
                else
                    % Find matching names
                    idxMatches = ismember({this.Projects.Name}, name);

                    % Make sure we found one project
                    assert(any(idxMatches), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project could not be found because it does not exist or names are too ambigious.');

                    % And return the first project that matches
                    p = this.Projects(find(idxMatches, 1, 'first'));
                end
            catch me
                % No match, so let's suggest projects based on their string
                % distance
                pclose = this.closest_projects(name);
                
                % Found similarly sounding projects?
                if ~isempty(pclose)
                    throwAsCaller(addCause(MException('PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project could not be found. Did you maybe mean one of the following projects?\n%s', strjoin(arrayfun(@(pp) pp.Name, pclose, 'UniformOutput', false), '\n')), me));
                else
                    throwAsCaller(addCause(MException('PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project could not be found. Make sure there is no typo in the name and that the project exists.'), me));
                end
            end
            
        end
        
        
        function varargout = list(this, prop)
            %% LIST the projects or a property of the projects
            
            
            % Default property
            if nargin < 2 || isempty(prop)
                prop = 'Name';
            end
            
            try
                % Return output?
                if nargout > 0
                    varargout{1} = {this.Projects.(prop)};
                % Directly display output
                else
                    disp({this.Projects.(prop)});
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function cd(this, name)
            %% CD to the project's folder
            
            
            try
                % Find project
                p = this.find(name);
                
                % Go to project
                p.cd();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function open(this, name)
            %% OPEN the project
            
            
            try
                % Find project
                p = this.find(name);
                
                % Only continue if project isn't loaded
                if ~p.IsLoaded
                    % Open project
                    p.open();
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function close(this, name)
            %% CLOSE the project
            
            
            try
                % Find project
                p = this.find(name);
                
                % Check if it is loaded
                if p.IsLoaded
                    % Close project
                    p.close();
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function startup(this, name)
            %% STARTUP executes the project's startup script/function
            %
            %   STARTUP(P) runs the project's startup script/function.
            
            
            try
                % Find project
                p = this.find(name);
                
                % Startup project
                p.startup();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function finish(this, name)
            %% FINISH executes the project's `finish` script/function
            %
            %   FINISH(P) runs the project's `finish` script/function 
            
            
            try
                % Find project
                p = this.find(name);
                
                % Finish project
                p.finish();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function varargout = reset(this)
            %% RESET the project manager object
            
            
            % Create a new instance of this object
            this = projman.manager();
            
            % Assign output?
            if nargout
                varargout{1} = this;
            end
            
        end
        
        
        function pd = pathdef(this, name)
            %% PATHDEF gets this projects `projpath()` result
            
            
            try
                % Find project
                p = this.find(name);
                
                % Get project's pathdef
                pd = p.pathdef();
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function pd = projpath(this, name)
            %% PROJPATH is a wrapper for PATHDEF
            %
            %   See also:
            %
            %   PROJMAN.MANAGER.PATHDEF
            
            
            pd = this.pathdef(name);
            
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function p = get.Loaded(this)
            %% GET.LOADED returns all loaded projects
            
            
            % Get all loaded projets
            p = this.Projects([this.Projects.IsLoaded]);
            
        end
        
    end
    
    
    
    %% SETTERS
    methods
        
        function set.Projects(this, ps)
            %% SET.PROJECTS validates the projects
            
            
            % These will be our unique projects
            P = projman.project.empty(1, 0);
            ii = 1;
            
            % Loop over each item of this
            while numel(ps)
                % Pop the current object off of O
                proj = ps(1);
                ps(1) = [];
                
                % Find projects with matching paths
                loMatches = proj == ps;
                
                % If there are no other matching paths, then we this project is
                % unique
                if ~any(loMatches)
                    P = horzcat(P, proj);
                % There are other objects that point to the same path so we will
                % merge them
                else
                    % Get the config
                    stConfig = proj.Config;
                    
                    % Merge all structs
                    stConfig = projman.helper.mergestructs(stConfig, ps(loMatches).Config);
                    
                    % Set the updated config
                    proj.Config = stConfig;
                    
                    % Append the unique array
                    P = horzcat(P, proj);
                    
                    % And now remove all the projects that were a match
                    ps(loMatches) = [];
                end
                
                % Increase loop counter
                ii = ii + 1;
            end
            
            % Set the cleaned array of projects
            this.Projects = P;
            
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
                save(projman.helper.filename(), 'p');
                
                % Free some memory
                clear('p');
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function C = horzcat(this, varargin)
            %% HORZCAT concatenates this project manager with another or a set of projects
            
            
            % Validate arguments
            try
                arrayfun(@(iArg) validateattributes(varargin{iArg}, {'projman.manager', 'projman.project'}, {'nonempty'}, mfilename, sprintf('arg(%g)', iArg)), 1:numel(varargin));
            catch me
                throwAsCaller(me);
            end
            
            % Find all objects that are of type PROJMAN.PROJECT
            loProjects = cellfun(@(x) isa(x, 'projman.project'), varargin);
            ceProjects = varargin(loProjects);
            % Find all objects that are of type PROJMAN.MANAGER
            loManagers = cellfun(@(x) isa(x, 'projman.manager'), varargin);
            ceManagers = varargin(loManagers);
            
            % Create output
            C = this;
            
            % Loop over each manager
            for iManager = 1:numel(ceManagers)
                C.Projects = horzcat(C.Projects, ceManagers{iManager}.Projects);
            end
            
            % And also assign each project
            C.Projects = horzcat(C.Projects, ceProjects{:});
            
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods ( Access = protected )
        
        
        function load_projects_(this)
            %% LOAD_PROJECTS_ loads the projects for this computer
            
            
            % Load the projects
            try
                % Create a matfile object
                moFile = matfile(projman.helper.filename());
                
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
        
        
        function ps = closest_projects(this, name)
            %% CLOSEST_PROJECTS finds the projects with a name closest to the needle
            
            
            % Get the distance between the needle and all other projects' names
            dists = cellfun(@(n) projman.manager.strdist(name, n), {this.Projects.Name});
            % Sort the distances from shortest to longest
            [dists, sortidx] = sort(dists);
            
            % Now get all projects whose name distance is smaller than 10 (some
            % random/arbitrary value)
            sortidx = sortidx(dists < 10);
            
            % And return these projects
            ps = this.Projects(sortidx);
            
        end
        
    end
    
end
