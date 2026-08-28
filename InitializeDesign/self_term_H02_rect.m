
function [I_self, Sshape] = self_term_H02_rect(k, eta, ax, ay, Jv, r0)
% SELF_TERM_RECT  Compute small-argument approximation of
%   I = -(k*eta/4) * ∫∫ Jv * H0^(2)(k*R) dS'  for a rectangle centered at origin
%
% Inputs:
%   k   - wavenumber
%   eta - medium impedance
%   ax  - half-width in x (a_x). Full width = 2*ax.
%   ay  - half-width in y (a_y). Full height = 2*ay.
%   Jv  - current value at observation point (scalar). If omitted assume 1.
%   r0  - small exclusion radius for analytic inner integral (optional, default 1e-6*min(ax,ay))
%
% Outputs:
%   I_self - complex self-term approximation (same units as original integral * Jv)
%   Sshape - shape constant S_shape as defined in the text
%
% Usage:
%   [I_self, Sshape] = self_term_rect(k, eta, ax, ay, Jv);
%
% Notes:
%  - Rectangle is centered at origin; observation point is at center.
%  - Numerical integration uses integral2 on the rectangle with inner disk omitted.
%  - r0 should be small but not too small for numeric; default is small fraction.
%
if nargin < 5 || isempty(Jv), Jv = 1; end
if nargin < 6 || isempty(r0), r0 = min(ax,ay)*1e-6; end

gammaE = 0.57721566490153286;

% area and equivalent radius
A = 4 * ax * ay;
a_eq = sqrt(A / pi);

% Analytic integral over the excluded small disk (radius r0)
% ∫_{0}^{r0} 2π r ln(k r / 2) dr = π r0^2 * ( ln(k r0 / 2) - 1/2 )
I_disk_analytic = pi * r0^2 * ( log(k * r0 / 2) - 1/2 );

% Numerical integral over rectangle excluding disk of radius r0:
% Integrand: ln( sqrt(x^2 + y^2) / a_eq ) = 0.5 * ln( (x^2+y^2) / a_eq^2 )
% We'll compute integral_ln = ∫∫ ln(R/a_eq) dA = I_disk_analytic_rel + I_rect_excl
% where I_disk_analytic_rel = ∫_{|r|<r0} ln(R/a_eq) dA = π r0^2*( ln(r0/a_eq) - 1/2 )
I_disk_analytic_rel = pi * r0^2 * ( log(r0 / a_eq) - 1/2 );

% Define integrand for integral2 (real-valued)
fun = @(xx,yy) log( sqrt(xx.^2 + yy.^2) / a_eq );

% Region: x in [-ax,ax], y in [-ay,ay], but exclude disk r<r0.
% We'll integrate over rectangle but mask region where sqrt(x^2+y^2) < r0 by returning 0,
% then add the analytic disk integral separately.
abs_tol = 1e-9;
rel_tol = 1e-6;

% Create wrapper integrand (vectorized) that returns 0 inside small disk
wrapper = @(xx,yy) arrayfun(@(xv,yv) ( ...
    (sqrt(xv^2+yv^2) <= r0) * 0 + (sqrt(xv^2+yv^2) > r0) * log( sqrt(xv^2+yv^2) / a_eq ) ...
    ), xx, yy);

% Perform numerical integration using adaptive integral2
% To improve robustness, integrate in two nested calls splitting y domain if needed
try
    integral_val = integral2(wrapper, -ax, ax, -ay, ay, 'AbsTol', abs_tol, 'RelTol', rel_tol);
catch ME
    % fallback: break into four quadrants to improve robustness
    integral_val = 0;
    integral_val = integral_val + integral2(wrapper, 0, ax, 0, ay, 'AbsTol',abs_tol,'RelTol',rel_tol);
    integral_val = integral_val + integral2(wrapper, -ax, 0, 0, ay, 'AbsTol',abs_tol,'RelTol',rel_tol);
    integral_val = integral_val + integral2(wrapper, -ax, 0, -ay, 0, 'AbsTol',abs_tol,'RelTol',rel_tol);
    integral_val = integral_val + integral2(wrapper, 0, ax, -ay, 0, 'AbsTol',abs_tol,'RelTol',rel_tol);
end

% Add analytic contribution of inner disk
integral_ln_over_rect = integral_val + I_disk_analytic_rel;

% Compute shape constant
Sshape = (1 / A) * integral_ln_over_rect;

% Now assemble the small-argument approximation (same form as derived earlier)
% I = -k*eta*A/4 * Jv + i * k*eta*A/(2*pi) * Jv * ( ln(k*a_eq/2) + gamma + Sshape )
I_real = - (k * eta * A / 4) * Jv;
I_imag =  (k * eta * A / (2*pi)) * Jv * ( log(k * a_eq / 2) + gammaE + Sshape );

I_self = I_real + 1i * I_imag;

end
