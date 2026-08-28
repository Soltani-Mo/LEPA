function Eout = IncidentEpatchArray( xv, yv, xj, yj, theta_i, phi_i, k0, nE, dy, CEMMN, er, h, a, b )


f0 = (3e8) * k0 / 2 / pi;
Eout = 0;


for qq = 1:nE

    arg0 = sqrt( ( (xv - xj(qq)).^2 ) + ( (yv - yj(qq)).^2 ) );

    arg1 = xv - xj(qq);

    arg2 = arg1 ./ arg0;

    My = 2 * Exx_Calc(xj(qq), yj(qq), f0, er, h, a, b, theta_i, phi_i);

    Eout = Eout + dy .* CEMMN .* My .* arg2 .* besselh(1, 2, k0 * arg0);


end


end