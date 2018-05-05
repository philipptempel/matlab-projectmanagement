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
        
        % Array of activated projects
        Activated
        
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
            
            % Check userpath is not empty
            if isempty(userpath)
                userpath('reset');
            end

            % Build the filename
            f = fullfile(userpath, sprintf('projects_%s.mat', matlab.lang.makeValidName(chComputername)));
            
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
                % Find matching names
                idxMatches = ismember({this.Projects.Name}, name);
                
                % Make sure we found any project
                assert(any(idxMatches), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:MANAGER:FIND:ProjectNotFound', 'Project could not be found because it does not exist or names are too ambigious');
                
                % And return the data
                p = this.Projects(idxMatches);
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
                    display({this.Projects.(prop)});
                end
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
                
                % Only continue if project isn't activated
                if ~p.IsActivated
                    % Activate project
                    p.activate();
                end
            catch me
                throwAsCaller(me);
            end
            
        end
        
        
        function deactivate(this, name)
            %% DEACTIVATE a project
            
            
            try
                % Find project
                p = this.find(name);
                
                % Check if it is activated
                if p.IsActivated
                    % Deactivate project
                    p.deactivate();
                end
            catch me
                throwAsCaller(me);
            end
        end
        
    end
    
    
    
    %% GETTERS
    methods
        
        function p = get.Activated(this)
            %% GET.ACTIVATED returns all activated projects
            
            
            % Find activated projects
            idx = [this.Projects.IsActivated];
            
            % If we found activated projects
            if ~isempty(idx)
                p = this.Projects(idx);
            % No activated projects found
            else
                p = projman.project.empty(1, 0);
            end
            
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
                    % Convert the logical values to linear indexes
                    idxMatches = find(loMatches);
                    
                    % Get the config
                    stConfig = proj.Config;
                    
                    % Loop over each match and merge the config
                    for iMatch = 1:numel(idxMatches)
                        stConfig = mergestructs(stConfig, ps(idxMatches(iMatch)).Config);
                    end
                    
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
            %% LOAD_PROJECTS_ loads the projects for this computer
            
            
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
