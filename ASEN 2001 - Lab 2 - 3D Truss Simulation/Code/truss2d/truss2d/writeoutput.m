function writeoutput(outputfile,inputfile,barforces,reacforces,joints,connectivity,reacjoints,reacvecs,loadjoints,loadvecs)
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

% open output file
fid=fopen(outputfile,'w');

% write header
fprintf(fid,'2-D Truss analysis\n');
fprintf(fid,'------------------\n\n');
fprintf(fid,'Date: %s\n\n',datestr(now));

% write name of input file
fprintf(fid,'Input file: %s\n\n',inputfile);

% write coordinates of joints
fprintf(fid,'Joints:         Joint-id  x-coordinate y-coordinate\n');
for i=1:size(joints,1)
    fprintf(fid,'%17d %12.2f %12.2f\n',i,joints(i,1),joints(i,2));
end
fprintf(fid,'\n\n');

% write external loads
fprintf(fid,'External loads: Joint-id  Force-x      Force-y\n');
for i=1:size(loadjoints,1)
    fprintf(fid,'%17d %12.2f %12.2f\n',loadjoints(i),loadvecs(i,1),loadvecs(i,2));
end
fprintf(fid,'\n');
    
% write connectivity and forces
fprintf(fid,'Bars:           Bar-id    Joint-i      Joint-j     Force    (T,C)\n');
for i=1:size(connectivity,1)
    if barforces(i)>0;tc='T';else tc='C';end
    fprintf(fid,'%17d   %7d %12d    %12.3f     (%s)\n',...
        i,connectivity(i,1),connectivity(i,2),abs(barforces(i)),tc);
end
fprintf(fid,'\n');

% write connectivity and forces
fprintf(fid,'Reactions:      Joint-id  Uvec-x       Uvec-y      Force\n');
for i=1:size(reacjoints,1)
    fprintf(fid,'%17d %12.2f %12.2f %12.3f\n',reacjoints(i),reacvecs(i,1),reacvecs(i,2),reacforces(i));
end

% close output file
fclose(fid);

end