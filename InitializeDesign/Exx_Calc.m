
function E_out = Exx_Calc(xv, yv, f0, er, d, a, b, theta, phi)


%% Constants

lam0 = (3e8)/f0;
k0 = 2*pi/lam0;
Z0 = 120*pi;


mn_mat = [0,0;-1,0;0,1;-3,0;3,0];
if phi == 0
    mode_num = 2;
    mn_mat = [0,0;-1,0;0,1;-3,0;3,0];

elseif phi == 90

    mode_num = 2;
    mn_mat = [0,0;-1,0;0,-1;0,3];

end

u = sind(theta)*cosd(phi);
v = sind(theta)*sind(phi);


%% Exx Loop

E_out = 0;

for i = 1:mode_num

    m = mn_mat(i,1);

    kx = (2*pi*m/a) + k0*u;

    n = mn_mat(i,2);

    ky = (2*pi*n/b) + k0*v;

    E_out = E_out +  ( -1i * Z0 / k0 ) * QXX(kx, ky, er, d, k0) .* exp( -1i * kx * xv ) .* exp( -1i * ky * yv );

end



end