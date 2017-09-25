clc

measurementV = input('measurement in uV: ');

error = ( 0.000065 * measurementV ) + ( 0.000035 * 100000 ); % using 2 year calibration & 100mV DCV range error

fprintf('Error is: %s uV\n', error);