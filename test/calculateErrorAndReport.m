%% Function to compare expected and actual outputs


function errorMsg = calculateErrorAndReport(expectedOutput, actualOutput, fn)
    errorMsg = 'Passed';
    
    if(isempty(find(size(expectedOutput) == size(actualOutput), 1)))
       errorMsg = sprintf(['\nSize does not match for ', fn '.']);
    end
    
    error = sum(abs(expectedOutput(:) - actualOutput(:)));
    if(error > 1e-08)
       errorMsg = sprintf(['Failed match for ', fn ,'.']);
    end
   
end