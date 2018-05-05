function pmi = pm(action)
% PM wrapper for projman.manager.instance()
%
%   PM() returns the current projman.manager instance or creates a new one if it
%   hasn't existed until called.
%
%   PM('reset') removes the old projman.manager instance and creates a new one
%   ultimately reading the project files anew.
%
%   Outputs:
%
%   M                   PROJMAN.MANAGER object
%
%   See also:
%       PROJMAN.MANAGER



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-04-15
% Changelog:
%   2018-04-15
%       * Initial release



%% Validate arguments

try
    % PM()
    % PM(ACTION)
    narginchk(0, 1);
    
    % PM(...)
    % M = PM(...)
    nargoutchk(0, 1);
    
    if nargin < 1 || 1 ~= exist('action', 'var') || isempty(action)
        action = 'instance';
    end
    
    validatestring(lower(action), {'', 'reset', 'instance'}, mfilename, 'action');
    
catch me
    throwAsCaller(me);
end



%% Do your code magic here

% Persistent object
persistent pm_

% No object yet or create new?
if isempty(pm_) || strcmpi(action, 'reset')
    pm_ = projman.manager();
end



%% Assign output quantities

% PMI = PM(...);
pmi = pm_;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
