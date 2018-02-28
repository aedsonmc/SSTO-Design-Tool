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
simTime = 650; %Simulation Time in Seconds
timestep = 0.1; %Simulation Time Step
totalIterations = simTime/timestep; %Number of Iterations
A = 650; %m^2 reference area
x = zeros(totalIterations,1);
xdot = zeros(totalIterations,1);
xdotdot = zeros(totalIterations,1);
y = zeros(totalIterations,1);
ydot = zeros(totalIterations,1);
ydotdot = zeros(totalIterations,1);
phi = zeros(totalIterations,1);
phidot = zeros(totalIterations,1);
phidotdot = zeros(totalIterations,1);
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
   ydot(i) = ydot(i-1) + ydotdot(i)*(timestep);
   y(i) = y(i-1) + ydot(i)*(timestep);
   xdotdot(i) = (F*cosd(phi(i-1))-CL(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*sind(phi(i-1))-CD(alpha(i-1))*(0.5*rho(y(i-1))*magu(i-1).^2*A)*cosd(theta(i-1)))/m(i-1);
   xdot(i) = xdot(i-1) + xdotdot(i)*(timestep);
   x(i) = x(i-1) + xdot(i)*(timestep);
   
   theta(i) = atand(ydot(i)/xdot(i));
   if y(i) < 30000
        m(i) = m(i-1) - mdot*timestep;
   else
        m(i) = m(i-1) - mdot*timestep - 727.2*timestep;
   end
   magu(i) = sqrt(xdot(i).^2+ydot(i).^2);
   magacc(i) = sqrt(xdotdot(i).^2 + ydotdot(i).^2);
   
   if magu(i) < 125
       phi(i) = 15;
       ydotdot(i) = 0;
       ydot(i) = 0;
       y(i) = 0;
   end
   if magu(i) >= 125
       if phi(i-1) < 45
           if phi(i-1) < 22.5
               phidotdot(i) = phidot(i-1) + 5*timestep;
           end
           if phi(i-1) >= 22.5
               phidotdot(i) = phidot(i-1) + (-5)*timestep;
           end 
       end
       if phi(i-1) >= 45
           phi(i) = 45;
           phidot(i) = 0;
           phidotdot(i) = 0;
       end
   end
    phi(i) = phi(i-1) + phidotdot(i) * timestep;
%    if (phi(i-1) <= 5)
%         phi(i) = phi(i-1) + 0.025;
%    else
%         phi(i) = phi(i-1);
%    end
% %    if magu(i-1) <= 100
% %        phi(i) = 0;
% %        ydot(i) = ydot(i-1);
% %        y(i) = y(i-1);
% %    end
   alpha(i) = phi(i) - atand(ydot(i)/xdot(i));
end

%% plot stuff
tplot = linspace(0,t,totalIterations);

figure(1)
plot(tplot,xdot)
title('X-Component')
xlabel('Time (s)')
ylabel('Velocity')

figure(2)
plot(tplot,ydot)
title('Y-Component')
xlabel('Time (s)')
ylabel('Velocity')

figure(3)
plot(magu,y/1000)
title('Velocity vs Altitude')
xlabel('Velocity')
ylabel('Altitude (km)')

figure(4)
plot(tplot,m)
title('Mass vs Time')
xlabel('Time')
ylabel('Mass (kg)')

figure(5)
plot(tplot,y/1000)
title('Altitude vs Time')
xlabel('Time')
ylabel('Altitude (km)')

figure(6)
plot(tplot,magu)
title('Velocity vs Time')
xlabel('Time')
ylabel('Velocity (m/s)')
