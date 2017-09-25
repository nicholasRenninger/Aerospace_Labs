function despinner_graphs(tan, rad, real)

%Each input should be a matrix with rows [t;al;w;T]
%% Tangent Release vs RadialGraphs
%al(t)
figure(1)
plot(tan(1,:), tan(2,:)) %tangent t vs alpha
hold on
plot(rad(1,:), rad(2,:)) %radial t vs alpha
plot(real(1,:), real(2,:)) %experimental t vs alpha
xlabel('time (s)')
ylabel('\alpha (rad/s^2)')
title('\alpha, Tangential Release')
legend('Tangent release, theoretical', 'Radial release, theoretical', ...
    'Radial release, experimental')

%w(t)
figure(2)
plot(tan(1,:), tan(3,:)) %tangent t vs w
hold on
plot(rad(1,:), rad(3,:)) %radial t vs w
plot(real(1,:), real(3,:)) %experimental t vs w
xlabel('time (s)')
ylabel('\omega (rad/s)')
title('\omega of Satellite')
legend('Tangent release, theoretical', 'Radial release, theoretical', ...
    'Radial release, experimental')

%T(t)
figure(3)
plot(tan(1,:), tan(4,:)) %tangent t vs T
hold on
plot(rad(1,:), rad(4,:)) %radial t vs T
plot(real(1,:), real(4,:)) %experimental t vs T
xlabel('time (s)')
ylabel('Tension (N)')
title('String Tension')
legend('Tangent release, theoretical', 'Radial release, theoretical', ...
    'Radial release, experimental')
end
