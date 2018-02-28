function output = CD(alpha)
load('CDdata.mat');
if alpha < -41
    alpha = -41;
end
if alpha > 41
    alpha = 41;
end
output = interp1(CDdata(:,1),CDdata(:,2),alpha,'nearest');