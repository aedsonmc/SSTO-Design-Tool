%% AEE480 VARDA Project Trajectory Solver
% Created by: Alex Edson
% Version date: Feb 16, 2018
% Values Obtained via CEARun, a NASA program

%% Purpose
% This code takes a series of inputs and iteratively solves for spacecraft
% position based on vector state space form equation.

%% To-DOs
% -Make function for accleration due to gravity with altitude
% -Make throttle function for mass flow and thrust
% -Create separate system for angle Psi to avoid discontinuities in the
% system
%% Main
clear,clc, close all

%Initialize Variables
g = 9.81;   %accleration due to gravity
m0 = 325000; %Initial Mass
mdot = 34.49; %mass flow for thrust. Will add throttleable settings based on chamber pressure and O/F ratios. For now thrust is constant
F = 1.6794e6; %maximum mass flow-based thrust
simTime = 60; %Simulation Time in Seconds
timestep = 0.01; %Simulation Time Step
totalIterations = simTime/timestep; %Number of Iterations
A = 100; %m^2 reference area
s = zeros(totalIterations,1); %initialize solution matricies
sdot = zeros(totalIterations,1);
sdotdot = zeros(totalIterations,1);
theta = zeros(totalIterations,1);
thetadot = zeros(totalIterations,1);
thetadotdot = zeros(totalIterations,1);
x = zeros(totalIterations,1);
y = zeros(totalIterations,1);
psi = zeros(totalIterations,1);
thetatgt = zeros(totalIterations,1);
alpha = zeros(totalIterations,1);
m = ones(totalIterations,1);
m(1) = m0;
dentemp = importdata('densityProfile.csv',','); %import density profile
rho = @(a) interp1(dentemp(:,1),dentemp(:,2),a,'nearest');
CLdata = importdata('CLoutput.csv',',');
CDdata = importdata('CDoutput.csv',',');
CL = @(a) interp1(CLdata(:,1),CLdata(:,2),a,'nearest');
CD = @(a) interp1(CDdata(:,1),CDdata(:,2),a,'nearest');

%Iterate
for i = 2:totalIterations
   t = i*timestep;
   sdotdot(i) = (F/m(i-1))*cosd(psi(i-1)-theta(i-1))-(CD(alpha(i-1))/(2*m(i-1)))*rho(y(i-1))*(sdot(i-1).^2)*A-g*sind(theta(i-1));
   s(i) = sdotdot(i)*((t.^2)/2);
   sdot(i) = sdotdot(i)*(t);
   thetadotdot(i) = (F/m(i-1))*sind(psi(i-1)-theta(i-1))+(CL(alpha(i-1))/(2*m(i-1)))*rho(y(i-1))*(sdot(i-1).^2)*A-g*sind(theta(i-1));
   theta(i) = thetadotdot(i)*((t.^2)/2);
   thetadot(i) = thetadotdot(i)*(t);
   
   x(i) = x(i-1) + s(i)*timestep*cosd(theta(i));
   if sdot < 100
       y(i) = 0;
   else
       y(i) = y(i-1) + s(i)*timestep*sind(theta(i));
   end

   m(i) = m(i-1) - mdot*timestep;
   if m(i-1) < 40000
       break 
   end
   if sdot(i) < 100
       alpha(i) = 5;
       psi(i) = 5;
   else
       alpha(i) = 15;
       psi(i) = 15;
       
   end
   
end

%% plot stuff
tplot = linspace(0,t,totalIterations);

figure(1)
plot(tplot,x)
title('X position vs Time')

figure(2)
plot(tplot,y)
title('Y position vs Time')

figure(3)
plot(tplot,s,tplot,sdot,tplot,sdotdot)
title('S')

figure(4)
plot(tplot,theta,tplot,thetadot,tplot,thetadotdot)
title('Theta')

