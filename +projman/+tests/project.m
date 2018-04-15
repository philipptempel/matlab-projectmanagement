classdef project < matlab.unittest.TestCase
    %PROJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods ( Test)
        
        function testCreateEmptyProject(tc)
            %% TESTCREATEEMPTYPROJECT
            
            
            % Import constraints
            import matlab.unittest.constraints.IssuesNoWarnings;
            import matlab.unittest.constraints.IsInstanceOf;
            import matlab.unittest.constraints.IsEqualTo;
            
            % Assert it works
            tc.assertThat(@() projman.project(pwd), IssuesNoWarnings());
            
            % Make an empty project
            p = projman.project(pwd);
            
            
            %%% Assertion
            % Check correct object type is returned
            tc.assertThat(p, IsInstanceOf('projman.project'));
            
        end
        
        
        function testProjectExists(tc)
            %% TESTPROJECTEXISTS
            
            
            % Import constraints
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.IsTrue;
            
            % Make an empty project
            p = projman.project(pwd);
            
            
            %%% Assertion
            % Check correct object type is returned
            tc.assertThat(p.Exists, IsTrue);
            % Check the project exists (since the path exists, it must exist,
            % too)
            tc.assertThat(exist(p), IsTrue);
            
        end
        
        
        function testResolveDependencies(tc)
            %% TESTRESOLVEDEPENDENCIES
            
            
            % Import constraints
            import matlab.unittest.constraints.IsTrue;
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.IsSameHandleAs;
            
            % Make some projects
            p(1) = projman.project(fullfile(pwd, 'independent'), 'Project 1');
            p(2) = projman.project(fullfile(pwd, 'base'), 'Project 2');
            p(3) = projman.project(fullfile(pwd, 'base', 'dependent_on_2'), 'Project 3', p(2));
            p(4) = projman.project(fullfile(pwd, 'base', 'dependent_on_2'), 'Project 4', p(2));
            p(5) = projman.project(fullfile(pwd, 'base', 'dependent_on_4'), 'Project 5', p(4));
            
            % Resolve the dependencies
            deps = p(5).resolve_dependencies();
            
            
            %%% Assertion
            % List of dependencies must be equal to this
            tc.assertThat(deps, IsEqualTo([p(2), p(3)]));
            % List of dependencies must be the same handles as
            tc.assertThat(deps, IsSameHandleAs([p(2), p(3)]));
            
        end
        
    end
    
end
