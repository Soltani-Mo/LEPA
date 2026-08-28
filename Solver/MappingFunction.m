function [eps_r_vec] = MappingFunction(p, NSh, NSt, NBase_P, bt, nLayers, beta1, beta2, beta3, er2, er1)

er_half = zeros(NSh * NSt/2, 1);

tt = 0;
for n = 1:bt:NSt/2
    if bt == 1
        tt = tt + 1;
    else
        if mod(n, bt) == 1
            tt = tt + 1;
        end
    end

    for m = 1:NBase_P:NSh
        

        mean_p_vec = zeros(1, bt);

        for q = 1:bt

            s1 = m + (n - 1 + q - 1) * nLayers * NBase_P;
            s2 = m - 1 + NBase_P + (n - 1 + q - 1) * nLayers * NBase_P;

            mean_p_local = mean(p(s1 : s2));

            mean_p_vec(q) = mean_p_local;

        end

        mean_p = mean(mean_p_vec);

        er_local = tanh(beta1 * mean_p + beta2 * ((1:NBase_P)-1) + beta3) * ( (er2 - er1) / 2 )+( (er2 + er1) / 2 );

        for q = 1:bt
            s1 = m + (n - 1 + q - 1) * nLayers * NBase_P;
            s2 = m - 1 + NBase_P + (n - 1 + q - 1) * nLayers * NBase_P;
            er_half(s1:s2) = er_local;
        end

    end

end

er_grid_half = reshape(er_half, [NSh NSt/2]);
er_grid = [ er_grid_half, flip(er_grid_half, 2)];
eps_r_vec = reshape(er_grid, 1, []);

end