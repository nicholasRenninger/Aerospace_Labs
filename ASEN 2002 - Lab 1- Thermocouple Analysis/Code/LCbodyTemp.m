close all
clear
clc

%x = [1420 1427 1433 1436 1446 1446 1447 1454 1448 1448]; microVolts
%y = [1436 1437 1434 1418 1411 1407 1405 1406 1397 1406]; microVolts
%x = [35.34 35.51 35.65 35.73 35.97 35.97 36.00 36.17 36.02 36.02]; % deg C
y = [35.73 35.75 35.68 35.29 35.11 35.01 34.97 34.99 34.77 34.99]; %deg C
%xError = [0.050 0.050 0.025 0.050 0.025 0.013 0.025 0.050 0.008 0.025]; %deg C
%yError = [0.025 0.005 0.018 0.010 0.050 0.025 0.050 0.010 0.025 0.015]; %deg C

STD = std(y);
YError = ones(1,10).*STD;

yMean = sum(y)/length(y);
YMean = ones(1,10);
mean = yMean.*YMean;
STDofMean = STD/sqrt(10);

plot(1:length(y),y,'b');
hold on
h2 = plot(1:10,mean,'g');
hold on
h1 = errorbar(y,YError);
hold on
h3 = plot(1:10,mean+STDofMean,'m');
hold on
plot(1:10,mean-STDofMean,'m');

%axis([0,10,30,40]);
title('Body Temperature Measurements (Lesser & Cooper)');
xlabel('Number of Measurements');
ylabel('Body Temperature (C)');
legend([h1 h2 h3], {'Body Temperature','mean','standard deviation of mean'});