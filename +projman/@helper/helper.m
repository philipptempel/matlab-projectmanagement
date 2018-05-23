classdef helper
    % HELPER are helper methods for package PROJMAN
    
    
    %% PUBLIC PROPERTIES
    properties
        
    end
    
    
    
    %% GENERAL STATIC METHODS
    methods ( Static )
        
        function f = filename()
            %% FILENAME returns the computer aware filename of the projects file
            
            
            % @see https://undocumentedmatlab.com/blog/unique-computer-id
            sid = '';
            ni = java.net.NetworkInterface.getNetworkInterfaces;
            while ni.hasMoreElements
                addr = ni.nextElement.getHardwareAddress;
                if ~isempty(addr)
                    sid = [sid, '.', sprintf('%.2X', typecast(addr, 'uint8'))];
                end
            end
            
            % Check userpath is not empty
            if isempty(userpath)
                userpath('reset');
            end

            % Build the filename
            f = fullfile(userpath, sprintf('projects_%s.mat', matlab.lang.makeValidName(sid)));
            
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

