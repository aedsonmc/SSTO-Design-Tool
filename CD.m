function output = CD(alpha,CDoutput)
%load('CDdata5mNacelles.mat');
if alpha < -41
    alpha = -41;
end
if alpha > 41
    alpha = 41;
end
output = interp1(CDoutput(:,1),CDoutput(:,2),alpha,'nearest');