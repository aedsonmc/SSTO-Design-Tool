function output = CD(alpha,CDoutput)
%load('CDdata5mNacelles.mat');
if alpha < -49
    alpha = -49;
end
if alpha > 49
    alpha = 49;
end
output = interp1(CDoutput(:,1),CDoutput(:,2),alpha,'nearest');