function f = filename()
% FILENAME returns the computer aware filename of the projects file
%
%   F = PROJMAN.FILENAME() returns the computer-aware projects file name.
%
%   Outputs:
%
%   F                   Fully qualified filename of the computer-aware projects
%                       file.
%
%   See also:
%       PROJMAN



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-10
% Changelog:
%   2018-02-10
%       * Initial release



%% Validate function call
try
    % PROJMAN.FILENAME()
    narginchk(0, 0);
    % PROJMAN.FILENAME()
    % F = PROJMAN.FILENAME()
    nargoutchk(0, 1);
catch me
    throwAsCaller(me);
end



%% Do your code magic here

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

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
