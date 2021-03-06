function [density] = rho(alt,dentemp)
%load('denprofile.mat')
if alt < 0
    alt = 0;
end
if alt > 50000
    alt = 50000;
end
density = interp1(dentemp(:,1),dentemp(:,2),alt,'nearest');