% AEE480 Varda Project
% Alex Edson
% CFD Data Extract code

clear,clc, close all
%% Import Data
CL = importdata('no_nacellesCL.csv');
CD = importdata('no_nacellesCD.csv');
CLpre = CL.data(:,2);
CLtime = CL.data(:,1);
CDpre = CD.data(:,2);
CDtime = CD.data(:,1);

%% Process Data
%Data was obtained by changing angle of attack by transient time in the
%CFD software. Therefore we need to take an average at every change.
totalCL = 0;
totalCD = 0;
count = 1;
for i = 1:50
   for j = count:count+50
      totalCL = totalCL + CLpre(j);
      totalCD = totalCD + CDpre(j);
   end
   avgCL = totalCL./50;
   avgCD = totalCD./50;
   totalCL = 0;
   totalCD = 0;
   CLpost(i) = avgCL;
   CDpost(i) = avgCD;
   count = count + 50;
   if count == 2451
       count = 2450;
   end
   
end
ClCd = CLpost./-CDpost;

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
plot(AOA,ClCd)
xlabel('AOA')
ylabel('Lift/Drag Ratio')
title('Biconvex 1 Subsonic Lift Drag Ratio')
grid on

figure(4)
plot(CLtime,CLpre)
xlabel('Iteration')
ylabel('CL')
title('Raw CL Data')

figure(5)
plot(CDtime,CDpre)
xlabel('Iteration')
ylabel('CD')
title('Raw CD Data')

%% Output useful data file
%Note initial model is symmetric about its centroid top plane and therefore
%we can simply invert the data for the negative angles of attack

CLoutput = [ (flipud(-AOA')) (flipud(-CLpost')) ; (AOA(2:end)') (CLpost(2:end)')];
CDoutput = [ (flipud(-AOA')) (flipud(-CDpost')) ; (AOA(2:end)') (CDpost(2:end)')];

save('CL_no_nacelles.mat','CLoutput')
save('CD_no_nacelles.mat','CDoutput')
% csvwrite('CLoutput.csv',CLoutput);
% csvwrite('CDoutput.csv',CDoutput);



