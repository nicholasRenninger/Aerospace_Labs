%%%

% set path of data files
path_Data = '..\Data\';
folder_path = cat(2, path_Data, '*.xlsx');

% Get Dir. for each set of data
dir_Data = dir(folder_path);

% determine number of each type of data file
num_Data_files = length(dir_Data);

% initialize Data cell arrays
data_cells = cell(num_Data_files, 1);

%%% Each Cell entry contains the contents of an entire group's data
%%% 
% read in velocity data from data files into cell array
% F, a, W, d_f
for i = 1:num_Data_files
   
    filename = cat(2, path_Data, dir_Data(i, 1).name);
    data_cells{i} = xlsread(filename);
    
end


