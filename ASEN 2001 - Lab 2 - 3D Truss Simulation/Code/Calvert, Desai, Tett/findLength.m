function [rods] = findLength(joints3D,connectivity,lDensity)
%Finds the length and weight of each rod

for i=1:length(connectivity)
   rods(i,1) = sqrt((((joints3D((connectivity(i,2)),1) - (joints3D((connectivity(i,1)),1))))^2 + (((joints3D((connectivity(i,2)),2) - (joints3D((connectivity(i,1)),2))))^2 + (((joints3D((connectivity(i,2)),3) - (joints3D((connectivity(i,1)),3))))^2))));
   rods(i,2) = rods(i,1)*lDensity*9.8;
end

end

