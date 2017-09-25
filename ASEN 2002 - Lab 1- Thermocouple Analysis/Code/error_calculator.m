clc
clear all

%measurementV = input('measurement in uV: ');
%pressure_high = input('high pressure value in kPa: ');
%pressure_low = input('low pressure value in kPa: ');
observed_error = input('observed error in measurement in uV: ');

is_sys_bias = input('is there a system bias? ');
if is_sys_bias == 1
    sys_bias = input('uncertainty in systematic bias in uV: ');
else
    sys_bias = 0;
end

is_boil_ref = input('is the reference boiling water? ');

if is_boil_ref == 1
    
    pressure_high = 83.819;
    pressure_low = 83.339;
    %error = ( 0.000065 * measurementV ) + ( 0.000035 * 100000 ); % using 2 year calibration & 100mV DCV range error

    boiling_point_high = 1/((8.314/40660)*log(101.325/pressure_high) + (1/373)) - 273;
    boiling_point_low = 1/((8.314/40660)*log(101.325/pressure_low) + (1/373)) - 273;

    boiling_point_error = boiling_point_high - boiling_point_low;
    
    ref_v_high = tempToVolt(boiling_point_high);
    ref_v_low = tempToVolt(boiling_point_low);
    ref_v_error = ref_v_high - ref_v_low;
    
else
    boiling_point_error = 0;
    ref_v_error = 0;
end




object_uncertainty = sqrt( observed_error^2 + ref_v_error^2 + sys_bias^2 );

%fprintf('\nMultiMeter Error is: %s uV\n', error);
fprintf('\nTemperature Error is: %f C\n', boiling_point_error);
fprintf('Reference Temp Voltage Error is: %f uV\n', ref_v_error);
fprintf('Object Uncertainty is: %f uV\n', object_uncertainty)