function p = instance()
% INSTANCE gets the singleton instance of PROJMAN
%
%   P = PROJMAN.INSTANCE() returns the singleton instance of the PROJMAN class
%
%   Outputs:
%
%   P                   Singleton instance of PROJMAN



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2018-02-10
% Changelog:
%   2018-02-10
%       * Initial release



%% Do your code magic here

persistent pm_

% Check the project manager instance is not empty and valid
if isempty(pm_) %|| ~isvalid(pm_)
    % Non-existent or invalid projman instance, so create a new one
    pm_ = projman();
end

% And return that property
p = pm_;


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
