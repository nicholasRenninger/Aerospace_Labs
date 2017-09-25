function ref_v = tempToVolt(t_ref)

    ref_v = (-1*17.600413686)+(38.921204975*(t_ref))+(1.85587700e-2*(t_ref)^2)+(-1*9.9457593e-5*(t_ref)^3)+(3.18409457e-7*(t_ref)^4)+(-1*5.607284e-10*(t_ref)^5)+(5.6075059e-13*(t_ref)^6)+(-1*3.202072e-16*(t_ref)^7)+(9.7151147e-20*(t_ref)^8)+(-1*1.210472e-23*(t_ref)^9)+(118.5976*exp(-1.183432e-4*(t_ref-126.9686)^2));

end