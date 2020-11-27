%% Script to unzip student submision and test it on test cases.
addpath('../Data/');

%% Parameters
pathToZipFiles = '../submission';%'../../../../submissions';
pathToUnzip = '../test/temp';
pathToFunadamentalTests = '../Data/TestFundamentals.mat';

%% Unzip files and grade
if ~exist(pathToUnzip, 'dir')
    mkdir(pathToUnzip);
end

addedPath = [];
dirinfo = dir(pathToZipFiles);
scoreboard = {};

for k = 3 : length(dirinfo)
    sprintf('Team Number: %d', k-2 );
    name = dirinfo(k).name;
    zipfilename = fullfile(pathToZipFiles, name);
    unzipFile = fullfile(pathToUnzip, sprintf('Team%d_%s', (k-2), name));
    unzip(zipfilename, unzipFile);
    allFolders = genpath([unzipFile, '/']);
    addpath(allFolders);
    rmpath('../Code/');
    % Testing
    testcaseTable = {};
    
    scoreboard{k-2, 1} = name;
    testcaseTable = checkFundamentals(testcaseTable, pathToFunadamentalTests);
    scoreboard{k-2, 2} = updateTable(testcaseTable{1, 1});
    scoreboard{k-2, 3} = cell2table(testcaseTable{1, 1});
    
    
    rmpath(allFolders);
    clear testcaseTable; clc;
end

scoreboard = cell2table(scoreboard);
scoreboard.Properties.VariableNames = {'Team' 'Result' 'TestResults'};

%% Check for fundamentals
function testcaseTable = checkFundamentals(testcaseTable, pathToFunadamentalTests)
   
    fprintf('\n\n------------------------------------\n');
    fprintf('Fundamental tests for all functions\n');
    
    
    %%
    pathToCam1Parameters = '../Data/vue2CalibInfo.mat';
    pathToCam2Parameters = '../Data/vue4CalibInfo.mat';
    pathToMocapJoints    = '../Data/Subject4-Session3-Take4_mocapJoints.mat';

    load(pathToCam1Parameters);
    load(pathToCam2Parameters);
    load(pathToMocapJoints);
    load(pathToFunadamentalTests);
    
    %%
    err = struct();
    fn = {'project3DTo2D', 'reconstruct3DFrom2D', 'findEpipolarLines'};
    checkPassed = true;
    
    for m = 1:size(test, 1)
        for n = 1:3
            testcase = fn{n};
            try
                switch(testcase)
                    case 'project3DTo2D'
                        cam1PixelCoords = project3DTo2D(vue2, test(m).worldCoord3DPoints);
                        if (size(cam1PixelCoords, 1) == 3), cam1PixelCoords = cam1PixelCoords(1:2, :); end
                        err.project3DTo2D.errorMsg1 = calculateErrorAndReport(test(m).cam1PixelCoords, cam1PixelCoords, testcase);
                        
                        cam2PixelCoords = project3DTo2D(vue4, test(m).worldCoord3DPoints);
                        if (size(cam2PixelCoords, 1) == 3), cam2PixelCoords = cam2PixelCoords(1:2, :); end
                        err.project3DTo2D.errorMsg2 = calculateErrorAndReport(test(m).cam2PixelCoords, cam2PixelCoords, testcase);

                    case 'reconstruct3DFrom2D'
                        recovered3DPoints = reconstruct3DFrom2D(vue2, test(m).cam1PixelCoords, vue4, test(m).cam2PixelCoords);
                        if (size(recovered3DPoints, 1) == 4), recovered3DPoints = recovered3DPoints(1:3, :); end
                        err.reconstruct3DFrom2D.errorMsg1 = calculateErrorAndReport(test(m).recovered3DPoints(1:3, :), recovered3DPoints, testcase);
                        
                    case 'findEpipolarLines'
                        [EpipolarLines1, EpipolarLines2] = findEpipolarLines(test(m).worldCoord3DPoints, vue2, test(m).cam1PixelCoords, vue4, test(m).cam2PixelCoords);
                        err.findEpipolarLines.errorMsg1 = calculateErrorAndReport(test(m).EpipolarLines1, EpipolarLines1, testcase);
                        err.findEpipolarLines.errorMsg2 = calculateErrorAndReport(test(m).EpipolarLines2, EpipolarLines2, testcase);
 
                end
                
                testcaseTable{m, 1}{n, 1} = testcase;
                testcaseTable{m, 1}{n, 2} = err.(testcase);
                testcaseTable{m, 1}{n, 3} = 'NA';

            catch ME
                err = sprintf('Exception');
                testcaseTable{m, 1}{n, 1} = testcase;
                testcaseTable{m, 1}{n, 2} = err;
                testcaseTable{m, 1}{n, 3} = [ME.identifier, ' -> ', ME.message];
            end
        end
    end
    
end


%%
function [result] = updateTable(testcaseTable)
    result = 'Passed';
    for i = 1:size(testcaseTable, 1)
        if(~strcmp(testcaseTable{i, 2}, 'Exception'))
            testCaseNames = fieldnames(testcaseTable{i, 2});
            for j=1:numel(testCaseNames)
                temp = strcmp(testcaseTable{i, 2}.(testCaseNames{j, 1}), 'Passed');
                if(~temp)
                    testcaseTable{i, 3} = 'Failed';
                    result = 'Failed';
                    break;
                end
            end
            if(~temp)
                break;
            end
        else
            result = 'Failed';
            return;
        end
    end
end
