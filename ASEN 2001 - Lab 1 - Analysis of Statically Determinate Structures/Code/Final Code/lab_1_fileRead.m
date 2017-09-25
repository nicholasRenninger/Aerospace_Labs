%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Takes a properly formatted input file named 2001LabInput.txt and provides
% 7 outputs, one for each category in the input file: then number of forces
% and moments, the coordinates of external forces, the magnitude and
% direction of external forces, the location of the external moments, the
% magnitude and direction of the external moments, the locations of the
% force supports, and the type and direction of the reaction. 
% It also returns the filename of the input file used to read from.
%
% Uses lines beginning with the pound symbol, #, to determine when a new
% category of data is about to be scanned. Checks for the special cases of
% no forces or no moments and will output a blank matrix in the place of
% data if no forces or moments exist.
%
% Authors: Nick Renninger, Cody Goldman
% Created: 29 August 2016
% Last Updated: 19 September 2016, Nick Renninger
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ forcesAndMoments, coordsOfExtForces , magAndDirOfExtForces , magAndDirMoments , forceReactionLocations, forceDirReaction, momDirReaction, filename_read] = lab_1_fileRead(filename)

    %%% initialization of all return parameters
    forcesAndMoments = [];
    coordsOfExtForces = [];
    magAndDirOfExtForces = [];
    locExtMoments = [];
    magAndDirMoments = [];
    supportLocations = [];
    forceDirReaction = [];
    momDirReaction = [];

    
    filename_read = cat( 2, '..\text_files\', filename); % create relative path to the input text file
    filename_read_full = cat(2, filename_read, '.txt');
    fid = fopen(filename_read_full, 'r');

    dataMat = cell(1,1); % initialize the cell matrix to hold text file lines
    i = 1;

    %%% Read Text file into Data Matrix
    while ~feof(fid)

       dataMat{i, 1} = fgets(fid);
       i  = i + 1;

    end

    % Get size of Data Mat
    r = size(dataMat,1);

    formatNum = 0; % this specifies which variables are currently being read

    % initializing indicies 
    coordForceIndex = 1;
    magAndDirForceIndex = 1;
    locExtMomentIndex = 1;
    magAndDirMomentIndex = 1;
    supportIndex = 1;
    forceDirIndex = 1;
    momDirIndex = 1;
    reactionSupportIndex = 1;

    % initialzing matricies
    supportLocations = zeros(6, 3);
    forceDirReaction = zeros(1, 3);
    momDirReaction = zeros(0, 3);
    forceReactionLocations = zeros(1, 3);
    
    for i = 1:r

       currentLine = dataMat{i, 1};

       if currentLine(1) == '#' % if first Character in line is # i.e. is commented line

            formatNum = formatNum + 1;

       else % reading values 

           if formatNum == 1 % num of ext forces and moments

               forcesAndMoments = cell2mat(textscan(currentLine, '%f '));
               numOfExtForces = forcesAndMoments(1);
               numOfExtMoments = forcesAndMoments(2);

               if numOfExtForces ~= 0 % intialize forces matricies if there are ext forces

                   coordsOfExtForces = zeros(numOfExtForces, 3);
                   magAndDirOfExtForces = zeros(numOfExtForces, 4);        
               end

               if numOfExtMoments ~= 0 % initialize moments matricies if there are ext moments

                   locExtMoments = zeros(numOfExtMoments, 3);
                   magAndDirMoments = zeros(numOfExtMoments, 4);
               end

           elseif formatNum == 3 && numOfExtForces ~= 0 % coords. of pts at which ext. forces are applied

               coordsOfExtForces(coordForceIndex, :) = rot90(cell2mat(textscan(currentLine, '%f')));
               coordForceIndex = coordForceIndex + 1;

           elseif formatNum == 5 && numOfExtForces ~= 0 % mag. and direction of ext. forces

               magAndDirOfExtForces(magAndDirForceIndex, :) = rot90(cell2mat(textscan(currentLine, '%f')));
               magAndDirForceIndex = magAndDirForceIndex + 1;

           elseif formatNum == 7 % location at which ext. couple moments are applied

               locExtMoments(locExtMomentIndex, :) = rot90(cell2mat(textscan(currentLine, '%f')));
               locExtMomentIndex = locExtMomentIndex + 1;

           elseif formatNum == 9 % mag. and direction of ext. couple moments

               magAndDirMoments(magAndDirMomentIndex, :) = rot90(cell2mat(textscan(currentLine, '%f')));
               magAndDirMomentIndex = magAndDirMomentIndex + 1;

           elseif formatNum == 11 % location of supports

               supportLocations(supportIndex, :) = rot90(cell2mat(textscan(currentLine, '%f')));
               supportIndex = supportIndex + 1;

           elseif formatNum == 13 % type and dir. of reaction

               dirOfReactionLine = textscan(currentLine, '%c %f %f %f'); % get line of from type and direction of reaction portion of textfile

               if dirOfReactionLine{1,1} == 'F' % is a force

                   forceDirReaction(forceDirIndex, :) = [dirOfReactionLine{1,2}, dirOfReactionLine{1,3}, dirOfReactionLine{1,4}]; % adding force to array
                   
                   forceReactionLocations(forceDirIndex, :) = supportLocations(reactionSupportIndex, :); % adding force support to array
                   
                   forceDirIndex = forceDirIndex + 1;
                  
               elseif dirOfReactionLine{1, 1} == 'M' % is a moment

                   momDirReaction(momDirIndex, :) = [dirOfReactionLine{1,2}, dirOfReactionLine{1,3}, dirOfReactionLine{1,4}];
                   momDirIndex = momDirIndex + 1;
               end
               
               reactionSupportIndex = reactionSupportIndex + 1; % increment support indexing every time a support is categorized as a reaction force support
               
           end

       end

    end

    fclose(fid);
    
end