% AEE480 VARDA Project Atmospheric Model
% Created by: Paul Gray
% Version date: Jan 19, 2018

% Atmospheric model code with additional calculations derived the
% model including:
%   Air flux through a defined inlet area as a function of speed
%   and altitude

% Three different models will be used:
%   Tri-fit Standard Model
%   Patched Exponential
%   Jacchia 1970

% An additional model from a prewritten code may also be used
%   MSISE-90

%% To Do %%
% - Add options for determining and plotting multiple velocities and/or
%   intake angles at once
% - Generate curve fit for Patched Exponential for lower altitudes
% - (Possibly) Add MSISE-90 data for lower altitudes
% - (Possibly) Add Jacchia 1970 model

%% Standard Variables
% All values are in metric

% Manual input area, vel, and theta
area = input(' Enter the intake area in m2 \n >> ');
vel = input(' Enter the velocity in m/s \n >> ');
theta = input(' Enter angle from vertical of intake in degrees \n >> ');
% Hardcoded area, vel, and theta
% area = 1;
% vel = 1;
% theta = 45;

alt = linspace(0,50000,50000);

%% Models
%%% Tri-fit Standard Model %%%
% Reference: https://www.grc.nasa.gov/www/k-12/airplane/atmosmet.html

% TSFM uses three curve fits derived from averaged sampled data
% divided into three regions: Troposphere, Lower Stratosphere, and
% Upper Stratosphere

% Note: density is not calcualted directly with this method, rather
% fits are given for temperature and pressure and density is then
% calcualted from those values (ie, density formula remains constant)

% Troposphere
% Altitudes < 11000 meters
temp_tri1 = 15.04 - 0.00649.*alt(1:11000);
pres_tri1 = 101.29.*((temp_tri1 + 273.1)./288.08).^5.256;
dens_tri1 = pres_tri1./ (0.2869.*(temp_tri1 + 273.1));

% Lower Stratosphere
% Altitudes between 11000 and 25000 meters
temp_tri2 = -56.46;
pres_tri2 = 22.65.*exp(1.73 - 0.000157.*alt(11001:25000));
dens_tri2 = pres_tri2./ (0.2869.*(temp_tri2 + 273.1));

% Upper Stratosphere
% Altitudes between 25000 and 100000 meters
temp_tri3 = -131.21 + 0.00299.*alt(25001:50000);
pres_tri3 = 2.488.*((temp_tri3 + 273.1)./216.6).^-11.388;
dens_tri3 = pres_tri3./ (0.2869.*(temp_tri3 + 273.1));

% Combine the three regimes into a single vector
dens_tri = [dens_tri1 dens_tri2 dens_tri3];

%%% Patched Exponential Model %%%
% Reference: http://ccar.colorado.edu/asen5050/projects/projects_2013/whitmire_ryder/

% Simple use of the barometric equation with respect to reference
% measurements for temperature, altitude, and scale height
% Referenced up to an altitude of 500km

% Reference measurements (metric):
height = [0 25 30 40 50 60 70 80 90 100 110 120 130 140 ...
    150 180 200 250 300 350 400 450 500].*1000;

nominaldensity = [1.225 3.899*10^-2 1.774*10^-2 3.972*10^-3 ...
    1.057*10^-3 3.206*10^-4 8.77*10^-5 1.905*10^-5 3.396*10^-6 ...
    5.297*10^-7 9.661*10^-8 2.438*10^-8 8.484*10^-9 3.845*10^-9 ...
    2.07*10^-9 5.464*10^-10 2.789*10^-10 7.248*10^-11 ...
    2.418*10^-11 9.518*10^-12 3.725*10^-12 1.585*10^-12 ...
    6.967*10^-12];

scaleheight = [7.249 6.349 6.682 7.554 8.382 7.714 6.549 ...
    5.799 5.382 5.877 7.263 9.472 12.636 16.149 22.523 ...
    29.74 37.105 45.546 53.628 53.298 58.515 60.828 63.822].*1000;

% Base height of the given atmospheric region (there are seven), lazy
% vector ordering of it
rhbase = [0 20 20 32 47 51 51 71 71 71 71 71 71 71 71 71 71 71 ...
    71 71 71 71 71].*1000;

% Barometric equation for density determination
% Does not account for latitudinal or semi-annual effects
dens_patched = nominaldensity.*exp(-1.*((height - rhbase)./scaleheight));

%%% Jacchia 1970 Model %%%
% Work in progress ...

%%% Plotting %%%
% Plotting density from model(s)
figure(1)
hold on
plot(dens_tri, alt./1000,'k','LineWidth',1.25)
plot([dens_tri(1),dens_tri(end)],[26,26],'r--')
xlim([0 dens_tri(1)])
title('Density vs Altitude')
xlabel('Air Density [kg/m^{3}]')
ylabel('Height [km]')

%% Air Mass Flow Rate %%
% theta is the angle of the intake from vertical

% Air and composite elements flow rates
airmdot_tri = dens_tri.*vel.*area.*cos(theta);
nimdot_tri = airmdot_tri.*0.7808;
oxmdot_tri = airmdot_tri.*0.2095;
armdot_tri = airmdot_tri.*0.0093;

%%% Plotting
% Plotting air mass flow rates as a funtion of altitude
figure(2)
hold on
plot(airmdot_tri,alt./1000,'k','LineWidth',1.2)
plot(nimdot_tri,alt./1000,'g','LineWidth',1.1)
plot(oxmdot_tri,alt./1000,'b','LineWidth',1.1)
plot(armdot_tri,alt./1000,'m','LineWidth',1.1)
plot([airmdot_tri(1),airmdot_tri(end)],[26,26],'r--')
legend('Total Air','Nitrogen','Oxygen','Argon','SR71 Ceiling')
xlim([0 airmdot_tri(1)])
title('Mass Flow Rate of Gases Through Engine Intakes vs Height')
xlabel('Mass Flow Rate [kg/s]')
ylabel('Altitude [km]')
