function t_meas = voltToTemp(v)

    t_meas = 2.508355e-2*(v)+7.860106e-8*(v)^2+(-1*2.503131e-10*(v)^3)+(8.315270e-14*(v)^4)+(-1*1.228034e-17*(v)^5)+(9.804036e-22*(v)^6)+(-1*4.413030e-26*(v)^7)+(1.057734e-30*(v)^8)+(-1*1.052755e-35*(v)^9);
    
end