
function [W_ipr, W_avg, W_max, W_min] = calcIPR(T, dy)
% Calculates inverse participation ratio width of each column
%
% Inputs:
%   T  : Ny_out x Ny_in spatial transfer matrix
%   dy : output spatial sampling (meters)
%
% Outputs:
%   W_ipr : IPR width for each input position
%   W_avg : average interaction width
%   W_max : maximum interaction width
%   W_min : minimum interaction width

Ny = size(T,2);

W_ipr = zeros(1,Ny);

for n = 1:Ny

    I = abs(T(:,n)).^2;      % intensity profile

    if sum(I)==0
        W_ipr(n)=0;
        continue
    end

    W_ipr(n) = (sum(I)^2)/(sum(I.^2))*dy;

end

W_avg = mean(W_ipr);
W_max = max(W_ipr);
W_min = min(W_ipr);

end