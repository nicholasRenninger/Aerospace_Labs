function [L_req, w, t] = despinner_radialplustangential(I, R, m, w_0, L_tan,t_tan)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% will fill in more later: files would refer to any intake filenames needed

%constants
c = I/(m*R^2)+1; %coefficient c, describes the angular momentum at initial conditions

%% Find required Length to despin satellite
syms w_f L
w_f = (m*R*w_0*sqrt(c)*(R+L)-(I+m*R^2)*w_0)/I == 0;
c = (I / (m *  R ^2)) + 1;
L_req = ( I / (m * R * sqrt(c)) ) + (R / sqrt(c)) - R;

%% Calculate w for tangential release portion
%Find t_tan from L_req = w_0*t_req*R;
t_tan = L_req/w_0/R;
t1 = linspace(0,t_tan);

%w(t), tan portion
w_tan = w_0*((c-w_0^2*t1.^2)./(c+w_0^2*t1.^2));

%% Calculate w for radial release portion
t_f = w_0*R/L_req;
if (t_tan < t_f)
    error('Time is wrong');
end

%As satellite keeps spinning, string wraps around satellite (starts
%shrinking)
t2 = linspace(t_tan,t_f,50);
L_rad = L_req - w_tan*(t2-t_tan) 
L = linspace(0,L_req);
%L = w_0*R*t;
w = (m*R*w_0*sqrt(c)*(R+w_0*R*t)-(I+m*R^2)*w_0)/I;
w_f = (m*R*w_0*sqrt(c)*(R+L_req)-(I+m*R^2)*w_0)/I;
wL =(m*R*w_0*sqrt(c)*(R+L1)-(I+m*R^2)*w_0)/I;

plot(t, w)
hold on
plot(L1,wL)
legend('w(t)','w(L)')

end

