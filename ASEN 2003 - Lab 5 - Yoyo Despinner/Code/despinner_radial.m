function [ output_args ] = despinner_radial(I, R, m, files)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% will fill in more later: files would refer to any intake filenames needed

%Find the length and time
[L, t] = radial_length(I, R, m, w_0);

%Intake/interpret experimental data

%Calculate alpha, omega, T and compare experimental
awTt_theor = radial_analyze_despin(I, R, m, L, w_0, t_f); %will probably need a data input also
radial_model_despin

%Graphs comparing experimental and model
end

