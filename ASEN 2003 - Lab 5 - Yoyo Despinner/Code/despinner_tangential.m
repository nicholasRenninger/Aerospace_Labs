function [ output_args ] = despinner_tangent(I, R, m)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
% Calculates experimental model of tangential despinner release for a
% satellite

% will fill in more later: files would refer to any intake filenames needed

%Find the length and time
[L, t] = tangent_length(I, R, m, w_0);

%Calculate alpha, omega, T and compare experimental
awTt = tangent_analyze_despin(I, R, m, L, w_0, t_f);

%% Graphs
%Angular velocity

%Angular acceleration

%Cord Tension

end

