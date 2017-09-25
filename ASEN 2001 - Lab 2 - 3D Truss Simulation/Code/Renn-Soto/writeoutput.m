function writeoutput(outputFile, inputFile, barForces, reacForces, joints, connectivity, reacJoints, reacVecs, loadJoints, loadVecs)
    % writeoutput(outputfile,inputfile,barforces,reacforces,joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs);
    %
    % output analysis results
    %
    % input:  outputfile   - name of output file
    %         inputfile    - name of input file
    %         barforces    - force magnitude in bars
    %         reacforces   - reaction forces
    %         joints       - coordinates of joints
    %         connectivity - connectivity 
    %         reacjoints   - joint id where reaction acts on
    %         reacvecs     - unit vector associated with reaction force
    %         loadjoints   - joint id where external load acts on
    %         loadvecs     - load vector
    %
    %
    % Author: Kurt Maute, Sept 21 2011
    % updated: Nicholas Renninger, Alexis Sotomayor, Sept 27 2016
    
    % open output file
    fid = fopen(outputFile,'w');

    % write header
    fprintf(fid, '3-D Truss analysis\n');
    fprintf(fid, '------------------\n\n');
    fprintf(fid, 'Date: %s\n\n', datestr(now));

    % write name of input file
    fprintf(fid, 'Input file: %s\n\n', inputFile);

    % write coordinates of joints
    fprintf(fid, 'Joints:         Joint-id  x-coordinate y-coordinate z-coordinate\n');
    for i = 1:size(joints, 1)
        fprintf( fid, '%17d %12.2f %12.2f %12.2f \n', i, joints(i, 1), joints(i, 2), joints(i, 3) );
    end
    fprintf(fid, '\n\n');

    % write external loads
    if size(loadJoints, 1) == 0
        numLoads = 0;
    else
        numLoads  = size(loadJoints, 2);
    end
    
    fprintf(fid, 'External loads: Joint-id  Force-x      Force-y      Force-z\n');
    for i = 1:numLoads
        fprintf( fid, '%17d %12.2f %12.2f %12.2f\n', loadJoints(i), loadVecs(i, 1), loadVecs(i, 2), loadVecs(i, 3) );
    end
    fprintf(fid,'\n');

    % write connectivity and forces
    fprintf(fid, 'Bars:           Bar-id    Joint-i      Joint-j     Force    (T,C)\n');
    for i = 1:size( connectivity, 1 )
        
        if barForces(i) > 0
            tc = 'T';
        else
            tc = 'C';
        end
        
        fprintf(fid, '%17d   %7d %12d    %12.3f     (%s)\n',...
            i, connectivity(i, 1), connectivity(i, 2), abs( barForces(i) ), tc);
        
    end
    fprintf(fid, '\n');

    % write connectivity and forces
    fprintf(fid, 'Reactions:      Joint-id  Uvec-x       Uvec-y      Uvec-z       Force\n');
    for i = 1:size( reacJoints, 1 )
        fprintf(fid, '%17d %12.2f %12.2f %12.2f %12.3f\n', reacJoints(i), reacVecs(i, 1), reacVecs(i, 2), reacVecs(i, 3), reacForces(i) );
    end

    % close output file
    fclose(fid);

end