close all
clc
hold on
for i = -2:0.1:2
    zeta = 1;
    w0 = 3;
    Kp = i;
    H = tf([w0^2*Kp],[1,(2*zeta*w0),(w0^2 + w0*Kp)]);
    stepplot(H)
    legend(sprintf('K_p = %0.2g', Kp))
end