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
            
            % Check correct object type is returned
            tc.assertThat(p.Exists, IsTrue);
            tc.assertThat(exist(p), IsTrue);
            
        end
        
    end
    
end