function [t, w, al] = import_data(fileID)
%% Get data from text file
%open file
data = load(fileID);

%% Set data for export
w = data(:, 2)*2*pi/60; %rpm->rad/s
t = data(:, 1);

%% Calculate angular acceleration al
dt = .01;
al = diff(w)/.01;
al = [al; 0];

end
