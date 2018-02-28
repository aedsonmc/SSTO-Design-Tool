function output = CL(alpha)
load('CLdata.mat');
if alpha < -41
    alpha = -41;
end
if alpha > 41
    alpha = 41;
end
output = interp1(CLdata(:,1),CLdata(:,2),alpha,'nearest');
