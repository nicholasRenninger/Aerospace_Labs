function [L_req, w, t] = despinner_radial(I, R, m, w_0)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% will fill in more later: files would refer to any intake filenames needed

%constants
c = I/(m*R^2)+1; %coefficient c, describes the angular momentum at initial conditions

% Find required Length to despin satellite
syms w_f L
w_f = (m*R*w_0*sqrt(c)*(R+L)-(I+m*R^2)*w_0)/I == 0;
c = (I / (m *  R ^2)) + 1;
L_req = ( I / (m * R * sqrt(c)) ) + (R / sqrt(c)) - R;


%Find omega_f
%t_f = w_0*R/L_req;
t = linspace(0,.5);
L1 = linspace(0,L_req);
%L = w_0*R*t;
w = (m*R*w_0*sqrt(c)*(R+w_0*R*t)-(I+m*R^2)*w_0)/I;
w_f = (m*R*w_0*sqrt(c)*(R+L_req)-(I+m*R^2)*w_0)/I;
wL =(m*R*w_0*sqrt(c)*(R+L1)-(I+m*R^2)*w_0)/I;

%{
plot(t, w)
hold on
plot(L1,wL)
legend('w(t)','w(L)')
%}
end

