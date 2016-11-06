function init()
% INIT initializes the project management tool



%% File information
% Author: Philipp Tempel <philipp.tempel@isw.uni-stuttgart.de>
% Date: 2016-10-30
% Changelog:
%   2016-10-30
%       * Initial release



%% Initialize projman

% Get projman's XML file name and folder
[chProjectsXml_FileName, chProjectsXml_FileFolder] = projman.projects_xml();

% Build path to the XML file
chProjectsXml_FilePath = fullfile(chProjectsXml_FileFolder, chProjectsXml_FileName);

% Check the file exists
if 2 == exist(chProjectsXml_FilePath, 'file')
    chResult = input('Project file exists, overwrite [yN]? ', 's');
    
    if ~any(strcmpi(chResult, {'y', 'yes'}))
        throwAsCaller(MException('PHILIPPTEMPEL:PROJMAN:INIT:ReInitCancelled', 'User canceled re-initialization of projman.'));
    end
end

% Create empty projects 


end

%------------- END OF CODE --------------
% Please send suggestions for improvement of this file to the original author as
% can be found in the header Your contribution towards improving this function
% will be acknowledged in the "Changes" section of the header
