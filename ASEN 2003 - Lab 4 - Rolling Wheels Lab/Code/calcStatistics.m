function calcStatistics(residuals, dataType)
    
    %%% calcStatistics(residuals, testType)
    %%%
    %%% Calculates the statistics of the calculated residuals, and prints
    %%% the results in a table to the command window and to a file in the
    %%% following directory:
    %%%                     ../Data/Data Statistics/
    %%%             
    %%% Inputs:
    %%%        - residuals: the vector of differences between experimental
    %%%                     results and the values predicted by the model.
    %%%        
    %%%        - dataType: string indicating which test was being run.
    %%%
    %%% Outputs:
    %%%         - writes statistics to command window and to an
    %%%         appropriately named file.
    %%%
    %%% Author: Nicholas Renninger
    %%% Date Created: 3/7/17
    %%% Last Modified: 3/14/17
    
    
    %% Calc Standard Deviation of the Residuals for Collar Velocity14
    sigma = std(residuals);
    
    
    %% Mean of the Residuals
    meanResidual = mean(residuals);
    
    
    %% Uncertainty of the Mean Residual
    numResiduals = length(residuals);
    sigmaMean = sigma / sqrt(numResiduals);
    
    
    %% Number of Observations
    numObservations = numResiduals;
    
    
    %% Number of Residuals that are greater than 3*simga
    num3SigmaResiduals = length(residuals(residuals > 3*sigma));
    
    
    %% Print to File
    
    % Creating File and Labeling what data is being Analyzed
    testName = sprintf('%s - Statistics', dataType);
    filename = sprintf('../Data/Data Statistics/%s.txt', testName);
    fid = fopen(filename, 'w+');
    
    %%%%%%%%%%%%%%% print to file %%%%%%%%%%%%%%%
    
    numBars = 82;
    
    % header
    fprintf(fid, '%s:\r\n\r\n', testName);
    fprintf(fid, ['|  sigma  |  mean residual  | sigma/sqrt(N) |', ...
                  '    N     | num. residuals > 3*sigma  |\r\n|']);
    
    % print horiz bars
    for i = 1:numBars
        fprintf(fid, '-');
    end
    
    % rest of data
    fprintf(fid,['|\r\n|%08.1g |    %09.3g    |   %08.1g    |   %04d   ', ...
             '|           %03d             |\r\n'], sigma,...
             meanResidual, sigmaMean, numObservations, num3SigmaResiduals);
    
    fclose(fid);
    
    
    %%%%%%%%%%%%%%% print to command window %%%%%%%%%%%%%%%
    numBars = 82;
    
    % header
    fprintf('\n%s:\n', testName);
    fprintf(['|  sigma  |  mean residual  | sigma/sqrt(N) |', ...
             '    N     | num. residuals > 3*sigma  |\n|']);
    
    % print horiz bars
    for i = 1:numBars
        fprintf('-');
    end
    
    % rest of data
    fprintf(['|\n|%08.1g |    %09.3g    |   %08.1g    |   %04d   ', ...
             '|           %03d             |\n'], sigma,...
             meanResidual, sigmaMean, numObservations, num3SigmaResiduals);
        
    
end
