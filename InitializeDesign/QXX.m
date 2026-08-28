

function out = QXX( kx, ky, er, d, k0 )

beta = sqrt((kx^2) + (ky^2));

k1temp = sqrt((er*(k0^2)) - (beta^2));
k1 = real(k1temp) - 1i*abs(imag(k1temp));
k2temp = sqrt((k0^2) - (beta^2));
k2 = real(k2temp) - 1i*abs(imag(k2temp));

Te = k1*cos(k1*d) + 1i*k2*sin(k1*d);
Tm = er*k2*cos(k1*d) + 1i*k1*sin(k1*d);

out = ((((er*(k0^2)) - (kx^2))*k2*cos(k1*d)) + (1i*((k0^2) - (kx^2))*k1*sin(k1*d))) ...
    *(sin(k1*d)/(Te*Tm));

end