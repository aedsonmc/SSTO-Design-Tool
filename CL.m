function output = CL(alpha,CLoutput)
%load('CLdata5mNacelles.mat');
if alpha < -49
    alpha = -49;
end
if alpha > 49
    alpha = 49;
end
output = interp1(CLoutput(:,1),CLoutput(:,2),alpha,'nearest');
