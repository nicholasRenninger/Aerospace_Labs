clear
clc

load('room_temp_24.dat')
load('boiling_temp_24.dat')


TC_room_Arr = room_temp_24(:, 2:5);
TC_boil_Arr = boiling_temp_24(:, 2:5);

mean_room_Arr = mean(TC_room_Arr);
mean_boil_Arr = mean(TC_boil_Arr);

num_room_samples = length(TC_boil_Arr);
num_boil_samples = length(TC_room_Arr);

for i = 1:4
        
       std_dev_mean_room = std(TC_room_Arr(i, :))/sqrt(num_room_samples);
       fprintf('Mean of Room Temp measurements for TC #%d in C: %f\tSTD Dev: %f\n', i, mean_room_Arr(i), std_dev_mean_room);
end

fprintf(' \n')

for i = 1:4
        
       std_dev_mean_boil = std(TC_boil_Arr(i, :))/sqrt(num_boil_samples);
       fprintf('Mean of Room Temp measurements for TC #%d in C: %f\tSTD Dev: %f\n', i, mean_boil_Arr(i), std_dev_mean_boil);
end
