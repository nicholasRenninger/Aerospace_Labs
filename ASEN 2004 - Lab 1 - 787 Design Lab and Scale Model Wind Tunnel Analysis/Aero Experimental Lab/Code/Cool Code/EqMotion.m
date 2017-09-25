function xdot = EqMotion(~,x)
%	Fourth-Order Equations of Aircraft Motion

	global CL CD S m g rho
	
	V 	=	x(1);
	Gam	=	x(2);
	q	=	0.5 * rho * V^2;	% Dynamic Pressure, N/m^2
	
	xdot	=	[(-CD * q * S - m * g * sin(Gam)) / m
				 (CL * q * S - m * g * cos(Gam)) / (m * V)
				 V * sin(Gam)
				 V * cos(Gam)];
             
    end