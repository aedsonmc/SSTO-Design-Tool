%% AEE480 VARDA Project Trajectory Solver
% Created by: Alex Edson
% Version date: Feb 26, 2018
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
timestep = 0.1; %Simulation Time Step
totalIterations = simTime/timestep; %Number of Iterations
A = 250; %m^2 reference area
x = zeros(totalIterations,1);
xdot = zeros(totalIterations,1);
xdotdot = zeros(totalIterations,1);
y = zeros(totalIterations,1);
ydot = zeros(totalIterations,1);
ydotdot = zeros(totalIterations,1);
phi = zeros(totalIterations,1);
theta = zeros(totalIterations,1);
alpha = zeros(totalIterations,1);
m = ones(totalIterations,1);
magu = zeros(totalIterations,1);
magacc = zeros(totalIterations,1);
m(1) = m0;
% dentemp = importdata('densityProfile.csv',','); %import density profile
% rho = @(a) interp1(dentemp(:,1),dentemp(:,2),a,'nearest');

%Iterate
for i = 2:totalIterations
   t = i*timestep;
   ydotdot(i) = (F*sind(phi(i-1))+CL(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*cosd(phi(i-1))-CD(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*sind(theta(i-1))-m(i-1)*g)/m(i-1);
   y(i) = ydotdot(i)*((t.^2)/2);
   ydot(i) = ydotdot(i)*(t);
   xdotdot(i) = (F*cosd(phi(i-1))-CL(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*sind(phi(i-1))-CD(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*cosd(theta(i-1)))/m(i-1);
   x(i) = xdotdot(i)*((t.^2)/2);
   xdot(i) = xdotdot(i)*(t);
   theta(i) = atand(ydot(i)/xdot(i));
   m(i) = m(i-1) - mdot*timestep;
   magu(i) = sqrt(xdot(i).^2+ydot(i).^2);
   magacc(i) = sqrt(xdotdot(i).^2 + ydotdot(i).^2);
   
%    if ydot(i-1) <= 100
%        phi(i) = 0;
%        ydot(i) = ydot(i-1);
%        y(i) = y(i-1);
%    end
   if (phi(i-1) <= 30)
        phi(i) = phi(i-1) + 0.5;
   else
        phi(i) = phi(i-1);
   end
   
   alpha(i) = phi(i) - atand(ydot(i)/xdot(i));
end

%% plot stuff
tplot = linspace(0,t,totalIterations);

figure(1)
plot(tplot,xdot,tplot,xdotdot)
title('X-Component')
xlabel('Time (s)')
ylabel('Velocity or Acceleration')
legend('Xvel','Xaccel')

figure(2)
plot(tplot,ydot,tplot,ydotdot)
title('Y-Component')
xlabel('Time (s)')
ylabel('Velocity or Acceleration')
legend('Yvel','Yaccel')

figure(3)
plot(magu,y/1000,magacc,y/1000)
title('Velocity vs Altitude')
xlabel('Velocity and Acceleration')
ylabel('Altitude (km)')
legend('VelMag','AccelMag')
