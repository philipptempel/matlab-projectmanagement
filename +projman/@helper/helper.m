classdef helper
    % HELPER are helper methods for package PROJMAN
    
    
    %% PUBLIC PROPERTIES
    properties
        
    end
    
    
    
    %% GENERAL STATIC METHODS
    methods ( Static )
        
        function f = filename()
            %% FILENAME returns the computer aware filename of the projects file
            
            
            % Reset user path
            if isempty(userpath())
              userpath('reset');
            end
            
            % File path
            chFile = fullfile(userpath(), '.projman');
            
            % Check if file does not exist
            if 2 ~= exist(chFile, 'file')
              % Create a unique computer ID
              chCompId = char(java.util.UUID.randomUUID);
              
              % Write computer ID to file
              try
                % File identifier
                hFid = fopen(chFile, 'w');
                
                % File closer as clean up
                coCloser = onCleanup(@() fclose(hFid));
                
                % Write to file
                fprintf(hFid, '%s', chCompId);
              catch me
                rethrow(me);
              end
            end
            
            % Read the file
            chCompId = strip(fileread(chFile));
            
            % Build filename
            f = fullfile(userpath(), sprintf('projects_%s.mat', matlab.lang.makeValidName(chCompId)));
            
        end
        
        
        function s = mergestructs(varargin)
            %% MERGESTRUCTS merges multiple structures into one
            %
            %   MERGESTRUCTS(S1, S2, ..., SN) merges structures S2, through
            %   SN into structure S1.
            %
            %   S = MERGESTRUCTS(S1, S2, ..., SN) returns the new structure.
            %
            %   Inputs:
            %
            %   S                   Structure
            %
            %   Outputs:
            %
            %   S                   Merged structure with fields of all
            %                       structures and values of the first
            %                       occurence of each field/value pair
            
            
            % Validate arguments
            try
                % MERGESTRUCTS(S1, ...)
                narginchk(1, Inf);
                
                % MERGESTRUCTS(...)
                % S = MERGESTRUCTS(...)
                nargoutchk(0, 1);
                
                % Ensure each argument is a structure
                arrayfun(@(ii) validateattributes(varargin{ii}, {'struct'}, {'nonempty'}, mfilename, sprintf('S%g', ii)), 1:nargin);
            catch me
                throwAsCaller(me);
            end
            
            
            % Get the base struct
            s = varargin{1};
            % Get all other structs
            os = varargin(2:end);

            % Loop over other structs
            for iS = 1:numel(os)
                % Get current structures fields
                fns = fieldnames(os{iS});

                % And merge these fields
                for iFn = 1:numel(fns)
                    s.(fns{iFn}) = os{iS}.(fns{iFn});
                end
            end
            
        end
        
    end
end

