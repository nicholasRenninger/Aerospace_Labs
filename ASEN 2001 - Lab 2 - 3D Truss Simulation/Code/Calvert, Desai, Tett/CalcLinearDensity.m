function [LinearDensity] = CalcLinearDensity(numRods)
%Calculates the linear density of numRods rods.
length = 0;
for i=1:numRods
   length = length + (input('Input a rod length: '));
end

mTotal = (input('Input a total mass: '));

LinearDensity = (mTotal/length);

end

