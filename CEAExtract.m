%% CEA Run Data Extract
%Alex Edson
%This code is for extracting specific data from CEARun (a NASA product)
%output files and plotting
clear,clc, close all

%% Extract Data
%These tabulated values all at 140atm chamber pressure
tabulated = importdata('TabulatedData.csv');
phi = tabulated.data(:,1);
OF = tabulated.data(:,2);
Tc = tabulated.data(:,3);
Tt = tabulated.data(:,4);
Te = tabulated.data(:,5);
Rho_exit = tabulated.data(:,6);
h = tabulated.data(:,7);
u = tabulated.data(:,8);
Mm = tabulated.data(:,9);
Cp_exit = tabulated.data(:,10);
gamma = tabulated.data(:,11);
sonicVel = tabulated.data(:,12);
M_exit = tabulated.data(:,13);
aeat = tabulated.data(:,14);
cstar = tabulated.data(:,15);
CF = tabulated.data(:,16);
ivac = tabulated.data(:,17);
isp = tabulated.data(:,18);
Ar = tabulated.data(:,19);
CH4 = tabulated.data(:,20);
CO = tabulated.data(:,21);
CO2 = tabulated.data(:,22);
H = tabulated.data(:,23);
H2 = tabulated.data(:,24);
H2O = tabulated.data(:,25);
NH3 = tabulated.data(:,26);
NO = tabulated.data(:,27);
NO2 = tabulated.data(:,28);
N2 = tabulated.data(:,29);
O = tabulated.data(:,30);
OH = tabulated.data(:,31);
O2 = tabulated.data(:,32);
ivacsec = ivac./9.81;
ispsec = isp./9.81;
mdot = 750; %kg/s
F = mdot.*cstar.*CF; %Equation 3-33(?) from Rocket Propulsion Elements


%Plot
figure(1)
plot(phi,OF)
title('OF vs Phi')
xlabel('Equivalence Ratio')
ylabel('O/F ratio')
grid on

figure(2)
plot(phi,Tc,phi,Tt,phi,Te)
title('Temperature vs Phi')
xlabel('Equivalence Ratio')
ylabel('Temperature (K)')
legend('Chamber','Throat','Exit','location','East')
grid on

figure(3)
plot(phi,Rho_exit)
title('Exit Density vs Phi')
xlabel('Equivalence Ratio')
ylabel('Density (kg/m^3)')
grid on

figure(4)
plot(phi,h,phi,u)
title('Exit Enthalpy and Internal Energy vs Phi')
xlabel('Equivalence Ratio')
ylabel('Energy kJ/kg')
legend('Enthalpy','Internal Energy')
grid on

figure(5)
plot(phi,Mm)
title('Molar Mass vs Phi')
xlabel('Equivalence Ratio')
ylabel('Molar Mass, g/mol')
grid on

figure(6)
plot(phi,Cp_exit,phi,gamma)
title('Cp and Gamma vs Phi')
xlabel('Equivalence Ratio')
ylabel('Specific Heat and Ratio')
legend('Cp Exit','Gamma','location','NorthWest')
grid on

figure(7)
plot(phi,sonicVel)
title('Sonic Velocity vs Phi')
xlabel('Equivalence Ratio')
ylabel('m/s')
grid on

figure(8)
plot(phi,M_exit,phi,aeat,phi,CF)
title('Exit Mach, Area Ratio, and CF vs Phi')
xlabel('Equivalence Ratio')
ylabel('Exit Mach or Area Ratio')
legend('Exit Mach','Ae/At','CF','location','East')
grid on

figure(9)
plot(phi,cstar)
title('C* vs Phi')
xlabel('Equivalence Ratio')
ylabel('C* m/s')
grid on

figure(10)
plot(phi,ivac,phi,isp)
title('Isp vs Phi')
xlabel('Equivalence Ratio')
ylabel('Isp (m/s)')
legend('Ivac','Isp','location','SouthEast')
grid on

figure(11)
plot(phi,ivacsec,phi,ispsec)
title('Isp vs Phi')
xlabel('Equivalence Ratio')
ylabel('Isp (sec)')
legend('Ivac','Isp','location','SouthEast')
grid on

figure(12)
plot(phi,Ar,phi,CH4,phi,CO,phi,CO2,phi,H,phi,H2,phi,H2O,phi,NH3,phi,NO,phi,NO2,phi,O,phi,O2,phi,OH)
title('Equivalence Ratio vs. Exit Species')
xlabel('Equivalence Ratio')
ylabel('Mole Fraction')
grid on
legend('Ar','CH4','CO','CO2','H','H2','H2O','NH3','NO','NO2','O','O2','OH')

figure(13)
plot(phi,F);
title('Thrust, 750 kg/s')
xlabel('Equivalence Ratio')
ylabel('Force')
grid on

