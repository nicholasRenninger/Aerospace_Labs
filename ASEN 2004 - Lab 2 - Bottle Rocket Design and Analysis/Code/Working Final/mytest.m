function mytest()
clear T
clear Y
options = odeset('RelTol', 1e-4, 'AbsTol', [1e-4 1e-4 1e-5], 'Events', @events, 'OutputFcn', @odeplot);
ode45(@func, [0 12], [0 1 1], options);
odeplot([],[],'done')
hold on
figure
options = odeset('RelTol', 1e-4, 'AbsTol', [1e-4 1e-4 1e-5], 'OutputFcn', @odeplot);
ode45(@func, [0 12], [0 1 1], options);
odeplot([],[],'done')
end


function dy = func(t,y)
dy=zeros(3,1);
dy(1) = y(2)*y(3);
dy(2) = -y(1)*y(3);
dy(3) = -0.51*y(1)*y(2);
end

function [value,isterminal,direction] = events(t,y)
value = y(1)-y(2);
isterminal = 1; % stop the integration
direction = 0; % all events
end