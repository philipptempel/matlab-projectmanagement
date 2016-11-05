classdef Projman
    % PROJMAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        projects
    end
    
    properties (SetAccess = immutable)
        filename
    end
    
    methods
        
        %{
        id = projman.add(name, path, dependencies = {})
            add a new project
        has = projman.exist(ID)
            check whether the given project exists
        success = projman.remove(id)
            remove a specific project
        success = projman.update(id, data = struct());
            update a specific project
        
        success = projman.save()
            save projects to file
        success = projman.flush()
            flush projects to file and reload
        
        id = projman.find(column, value)
            find ID of a project given a certain value to find in a column
            projman.find('name', ...)
            projman.find('path', ...)
        
        projman.depends(pendent, dependent)
            check whether pendent depends on dependent or not (directly or
            indirectly)
        projman.dependents(ID)
            resolves dependencies and gets projects that depend onto this one
            (directly and indirectly)
        projman.has_dependents(ID)
            checks whether the given project has dependents (direct or indirect)
        projman.dependencies(ID)
            
        %}
        
        function obj = Projman(chFilename)
            % PROJMAN creates a new project manager object
            
            % Number of input arguments must be one
            narginchk(1,1);
            
            % Is the file anywhere on the path?
            if ~isempty(which(chFilename))
                % Get folder, file name, and extension
                [chFile_Folder, chFile_Name, chFile_Ext] = fileparts(which(chFilename));
            % File is no where on the path
            else
                % Get folder, file name, and extension
                [chFile_Folder, chFile_Name, chFile_Ext] = fileparts(chFilename);
                
                % No folder? Default to current working directory
                if isempty(chFile_Folder)
                    chFile_Folder = pwd;
                end
            end
            
            % Build the FQFN
            obj.filename = fullfile(chFile_Folder, [chFile_Name, chFile_Ext]);
            
            % Assert file given is a '.csv' file and that it actually exists
            assert(strcmp('.csv', chFile_Ext), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:InvalidFileType', 'Invalid file extension %s given. Only accepts %s.', chFile_Ext, '.csv');
            assert(2 == exist(obj.filename, 'file'), 'PHILIPPTEMPEL:PROJMAN:PROJMAN:InvalidFile', 'Invalid file %s given.', obj.escapepath([chFile_Name, chFile_Ext]));
            
            % Load the CSV and assign it to the local projects variable
            try
                obj.projects = readtable(obj.filename, 'Delimiter', ',');
            catch me
                throwAsCaller(addCause(MException('PHILIPPTEMPEL:PROJMAN:PROJMAN:UnableToLoadDatabase'), me));
            end
        end
        
        
        function status = exist(obj, ID)
            % EXIST checks whether the given project ID exists or  not
            status = any(strcmp(obj.projects.ID, ID));
        end
        
        
        function status = unique(obj, ID)
            % UNIQUE checks for unique project ID
            status = ~obj.exist(ID);
        end
        
        
        function id = find(obj, chColumn, mxValue)
            % FIND finds the ID for the project matching the value in a specific
            % column
            if ~any(ismember(obj.projects.Properties.VariableNames, chColumn))
                throwAsCaller(MException('PHILIPPTEMPEL:PROJMAN:FIND:InvalidColumn', 'Invalid column %s given.', chColumn));
            end
            
            % Find all matching items
            idxMatch = strcmp(obj.projects.(chColumn), mxValue);
            
            % If there was a match, grab the ID of the match, otherwise return
            % an empty char array
            if any(idxMatch)
                id = obj.projects.ID{find(idxMatch, 1, 'first')};
            else
                id = '';
            end
        end
        
        
        function obj = add(obj, chName, chBase, ceDependencies)
            % ADD adds a new project to the list
            
            narginchk(3, 4);
            
            % Default dependencies: empty
            if nargin < 4
                ceDependencies = {};
            end
            
            % Get a full path to the project folder
            chBase = projman.fullpath(chBase);
            
            % Name: non-empty, char
            assert(~isempty(chName), 'PHILIPPTEMPEL:PROJMAN:ADD:EmptyArgument', 'Argument %s must be non-empty.', 'Name');
            assert(isa(chName, 'char'), 'PHILIPPTEMPEL:PROJMAN:ADD:InvalidType', 'Argument %s must be of type %s.', 'Name', 'char');
            
            % Base: non-empty, char, exists as dir
            assert(~isempty(chBase), 'PHILIPPTEMPEL:PROJMAN:ADD:EmptyArgument', 'Argument %s must be non-empty.', 'Base');
            assert(isa(chBase, 'char'), 'PHILIPPTEMPEL:PROJMAN:ADD:InvalidType', 'Argument %s must be of type %s.', 'Base', 'char');
            assert(7 == exist(chBase, 'dir'), 'PHILIPPTEMPEL:PROJMAN:ADD:InvalidDir', 'Argument %s must be a valid directory.', 'Base');
            
            % Depdendencies: cell, vector
            assert(isa(ceDependencies, 'cell'), 'PHILIPPTEMPEL:PROJMAN:ADD:InvalidType', 'Argument %s must be of type %s.', 'Dependencies', 'cell');
            
            % Check the dependencies are available
            cellfun(@(chUUID) obj.exist(chUUID), ceDependencies);
            % Check the project (i.e., the path) hasn't yet been added
            assert(isempty(obj.find('Path', chBase)), 'PHILIPPTEMPEL:PORJMAN:ADD:DoubleProjectBase', 'Folder at %s already added as project.', obj.escapepath(chBase));
            
            % Create a structure for the new project
            stNewProject = struct( ...
                'ID', {{obj.create_id()}} ...
                , 'Name', {{chName}} ...
                , 'Path', {{projman.fullpath(chBase)}} ...
                , 'Dependencies', {{projman.strjoin(ceDependencies, ',')}} ...
            );
            
            % Append the structure as table to the existing table
            obj.projects = [obj.projects; struct2table(stNewProject)];
        end
        
        
        function obj = update(obj, chUUID, stData)
            % UPDATE upates the data for the givne project
            
            narginchk(3, 3);
            
            % Assert this object has the given project UUID
            assert(obj.has(chUUID), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidID', 'Invalid project ID %s given.', chUUID);
            
            % Data: struct, non-empty
            assert(isa(stData, 'struct'), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidType', 'Argument %s must be of type %s.', 'Data', 'struct');
            assert(~isempty(stData), 'PHILIPPTEMPEL:PROJMAN:UPDATE:EmptyArgument', 'Argument %s must be non-empty.', 'Data');
            % Validate field 'Name'
            assert(~isfield(stData.Name) || isa(stData.Name, 'cell'), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidType', 'Argument %s must be of type %s.', 'Data.Name', 'char');
            % Validate field 'Path'
            assert(~isfield(stData.Path) || isa(stData.Path, 'cell'), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidType', 'Argument %s must be of type %s.', 'Data.Path', 'char');
            assert(~isfield(stData.Path) || isdir(stData.Path), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidType', 'Argument %s must be a valid directory', 'Data.Path');
            % Validate field 'Dependencies'
            assert(~isfield(stData.Dependencies) || isa(stData.Dependencies, 'cell'), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidType', 'Argument %s must be of type %s.', 'Data.Dependencies', 'cell');
            assert(~isfield(stData.Dependencies) || obj.valid_dependencies(stData.Dependencies), 'PHILIPPTEMPEL:PROJMAN:UPDATE:InvalidDependencies', 'Invalid dependencies given.');
            
            % Assert dependencies
            if isfield(stData, 'Dependencies')
                obj.valid_dependencies(stData.Dependencies);
            end
            
            % Get the index of the project in the local storage
            idxProject = strcmp(obj.projects.ID, chUUID);
            stProject = table2struct(obj.projects(idxProject,:));
            
            % Loop over each column of the local projects table
            for iCol = 1:numel(obj.projects.Properties.VariableNames)
                % Get the field name as we will be using it repeatedly
                chField = obj.projects.Properties.VariableNames{iCol};
                
                % Don't allow updating the ID
                if strcmpi(chField, 'id')
                    continue
                end
                
                % Update the project's value if it was given in the new data
                % struct
                if isfield(stData, chField)
                    stProject.(chField) = stData.(chField);
                end
            end
            
            % Update the respective row
            obj.projects(idxProject,:) = struct2table(stProject);
        end
        
        function obj = remove(obj, chUUID)
            % REMOVE removes a project from the internal project table
            
            narginchk(2, 2);
            
            % Assert this object has the given project UUID
            assert(obj.has(chUUID), 'PHILIPPTEMPEL:PROJMAN:REMOVE:InvalidID', 'Invalid project ID %s given', chUUID);
            
            % Check project has no dependencies
            for iProj = 1:numel(obj.projects.ID)
                if strfind(obj.projects.Dependencies{iProj}, chUUID)
                    throwAsCaller(MException('PHILIPPTEMPEL:PROJMAN:REMOVE:HasDependencies', 'Not removing project that other projects depend on.'));
                end
            end
            
            % Remove the project with the given UUID
            obj.projects(strcmp(obj.projects.ID, chUUID)) = [];
        end
        
        
        function chUUID = create_id(obj)
            % CREATE_ID creates a unique ID
            
            narginchk(1, 1);

            % Create a random UUID using Java's randomUUID function
            chUUID = char(java.util.UUID.randomUUID);
            
            % Make sure the ID really is unique and create new ones as long as
            % the ID already exists
            while obj.exist(chUUID)
                chUUID = char(java.util.UUID.randomUUID);
            end
            
        end
        
        
        function status = valid_dependencies(obj, ceDependencies)
            % VALID_DEPENDENCIES checks that all given dependencies are valid
            
            narginchk(2, 2);
            
            % If any dependencies are given, we'll just loop over the cell array
            % and check each UUID exists. Then we'll take the `all` of these.
            status = isempty(ceDependencies) || all(cellfun(@(chUUID) obj.exist(chUUID), ceDependencies));
        end
%         
%         function has = has(obj, chUUID)
%             % HAS checks for the existence of the project ID in the local
%             % storage
%             narginchk(2, 2);
%             
%             % UUID must be a char
%             try
%                 assert(isa(chUUID, 'char'), 'PHILIPPTEMPEL:PROJMAN:HAS:InvalidType', 'Argument %s must be of type %s.', 'UUID', 'char');
%             catch me
%                 throwAsCaller(me);
%             end
%             
%             % Just check for the existence of the UUID in the ID column
%             has = any(strcmp(chUUID, obj.projects.ID));
%         end
%         
%         function obj = save(obj)
%             % SAVE saves the internal projects table to a csv file
%             try
%                 writetable(obj.projects, obj.filename, 'Delimiter', ',', 'FileType', 'text');
%             catch me
%                 throwAsCaller(addCause(MException('PHILIPPTEMPEL:PROJMAN:PROJMAN:WriteFail', 'Failed to save projects file at %s.', obj.escapepath(obj.filename)), me));
%             end
%         end
%         
%         function base = find(obj, chPath)
%             idxProjectNo = strcmp(chPath, obj.projects.Path);
%             base = '';
%             
%             if any(idxProjectNo)
%                 base = obj.projects.ID{idxProjectNo};
%             end
%         end
%         
%         function valid_dependencies(obj, ceDependencies)
%             % VALID_DEPENDENCIES checks that all given dependencies are valid
%             try
%                 cellfun(@(chUUID) assert(obj.has(chUUID)), ceDependencies)
%             catch me
%                 throwAsCaller(me)
%             end
%         end
%         
%         function ceResolved = resolve_dependencies(obj, chUUID)
%             try
%                 obj.has(chUUID);
%             catch me
%                 throwAsCaller(me);
%             end
%             
%             chDependencies = obj.projects.Dependencies{strcmp(obj.projects.ID, chUUID)};
%             ceResolved = {};
%             
%             if ~isempty(chDependencies)
%                 ceDependencies = strsplit(chDependencies, ',');
%                 
%                 for iProj = 1:numel(ceDependencies)
%                     ceResolved = horzcat(ceResolved, ceDependencies{iProj});
%                 end
%             end
%         end
    end
    
    methods (Static)
        function escaped = escapepath(chFilepath)
%             escaped = strrep(chFilepath, '\', '\\');
            escaped = chFilepath;
        end
    end
    
end

