% AEE480 Varda Project
% Alex Edson
% CFD Data Extract code

clear,clc, close all
%% Import Data
CL = importdata('Biconvex1CL.csv');
CD = importdata('Biconvex1CD.csv');
CLpre = CL.data(:,2);
CLitr = CL.data(:,1);
CDpre = CD.data(:,2);
CDitr = CD.data(:,1);

%% Process Data
%Data was obtained by changing angle of attack by iteration number in the
%CFD software. Therefore we need to take an average at every change.
itr = 900;
count = 1;
while itr <= 4900
    totalCL = sum(CLpre(itr:itr+100));
    avgCL = totalCL/100;
    CLpost(count) = avgCL;
    totalCD = sum(CDpre(itr:itr+100));
    avgCD = totalCD/100;
    CDpost(count) = avgCD;
    count = count + 1;
    itr = itr + 100;
end


%% Plot Data
AOA = 0:length(CLpost)-1;

figure(1)
plot(AOA,CLpost)
xlabel('Angle of Attack')
ylabel('CL')
title('Biconvex 1 Subsonic CL')
grid on

figure(2)
plot(AOA,CDpost)
xlabel('Angle of Attack')
ylabel('CD')
title('Biconvex 1 Subsonic CD')
grid on

figure(3)
plot(CDpost,CLpost)
xlabel('CD')
ylabel('CL')
title('Biconvex 1 Subsonic Polar')
grid on