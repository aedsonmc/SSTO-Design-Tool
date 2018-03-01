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
simTime = 1400; %Simulation Time in Seconds
timestep = 0.5; %Simulation Time Step
totalIterations = simTime/timestep; %Number of Iterations
A = 685.597; %m^2 reference area

x = zeros(totalIterations,1,'gpuArray');
xdot = zeros(totalIterations,1,'gpuArray');
xdotdot = zeros(totalIterations,1,'gpuArray');
y = zeros(totalIterations,1,'gpuArray');
ydot = zeros(totalIterations,1,'gpuArray');
ydotdot = zeros(totalIterations,1,'gpuArray');
phi = zeros(totalIterations,1,'gpuArray');
phidot = zeros(totalIterations,1,'gpuArray');
phidotdot = zeros(totalIterations,1,'gpuArray');
theta = zeros(totalIterations,1,'gpuArray');
alpha = zeros(totalIterations,1,'gpuArray');
m = ones(totalIterations,1,'gpuArray');
magu = zeros(totalIterations,1,'gpuArray');
magacc = zeros(totalIterations,1,'gpuArray');
Q = zeros(totalIterations,1,'gpuArray');
m(1) = m0;
load('denprofile.mat') %to reduce call time on rho function
load('CDdata5mNacelles.mat')
load('CLdata5mNacelles.mat')
% dentemp = importdata('densityProfile.csv',','); %import density profile
% rho = @(a) interp1(dentemp(:,1),dentemp(:,2),a,'nearest');

%Iterate
for i = 2:totalIterations
   t = i*timestep;
   rhoi = rho(y(i-1),dentemp(:,:));
   CLi = CL(alpha(i-1),CLoutput(:,:));
   CDi = CD(alpha(i-1),CDoutput(:,:));
   ydotdot(i) = (F*sind(phi(i-1))+CLi*(0.5*rhoi*magu(i-1).^2*A)*cosd(phi(i-1))-CDi*(0.5*rhoi*magu(i-1).^2*A)*sind(theta(i-1))-m(i-1)*g)/m(i-1);
   ydot(i) = ydot(i-1) + ydotdot(i)*(timestep);
   y(i) = y(i-1) + ydot(i)*(timestep);
   xdotdot(i) = (F*cosd(phi(i-1))-CLi*(0.5*rhoi*magu(i-1).^2*A)*sind(phi(i-1))-CDi*(0.5*rhoi*magu(i-1).^2*A)*cosd(theta(i-1)))/m(i-1);
   xdot(i) = xdot(i-1) + xdotdot(i)*(timestep);
   x(i) = x(i-1) + xdot(i)*(timestep);
   
   theta(i) = atand(ydot(i)/xdot(i));
   if y(i) < 30000
        m(i) = m(i-1) - mdot*timestep;
   else
        m(i) = m(i-1) - mdot*timestep - 22*mdot*timestep;
   end
   if m(i) < 32500
       m(i) = m(i-1);
       F = 0;
   end
   magu(i) = sqrt(xdot(i).^2+ydot(i).^2);
   magacc(i) = sqrt(xdotdot(i).^2 + ydotdot(i).^2);
   Q(i) = 0.5*rhoi*magu(i).^2;
   %takeoff values
   if magu(i) < 100
       phi(i) = 5;
       ydotdot(i) = 0;
       ydot(i) = 0;
       y(i) = 0;
   end

   %Climb Section
   if magu(i) >= 100
      phi(i) = 10;
       if y(i) >= 12500
           phi(i) = 2;
           phidotdot(i) = 0;
       end
       if magu(i) >= 6000
           phi(i) = 20;
       end
       if y(i) >= 80000
           phi(i) = 10;
           F = 0;
           m(i) = m(i-1);
       end
       if y(i) >= 1.2e5
           phi(i) = 0.5;
           F = 1.6794e6;
           m(i) = m(i-1) - (mdot+22*mdot)*timestep;
       end
   end
   
   alpha(i) = phi(i) - atand(ydot(i)/xdot(i));
   %coasting section
%    if y(i) > 60000
%        F = 0;
%        m(i) = m(i-1);
%    end
%    if m(i) < 40000
%        F = 0;
%        m(i) = m(i-1);
%    end
%    if t > 768
%        phi(i) = 2;
%        phidot(i) = 0;
%        phidotdot(i) = 0;
%        F = 1.6794e6;
%        m(i) = m(i-1) - mdot*timestep - 22*mdot*timestep;
%    end
end

%% plot stuff
tplot = linspace(0,t,totalIterations);
mach = magu./340;

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
plot(mach,y/1000)
title('Mach vs Altitude (normalized to SL)')
xlabel('Mach')
ylabel('Altitude')

figure(5)
plot(tplot,m)
title('Mass vs Time')
xlabel('Time')
ylabel('Mass (kg)')

figure(6)
plot(tplot,y/1000)
title('Altitude vs Time')
xlabel('Time')
ylabel('Altitude (km)')

figure(7)
plot(tplot,magu)
title('Velocity vs Time')
xlabel('Time')
ylabel('Velocity (m/s)')

figure(8)
plot(tplot,phi)
title('Phi vs Time')
xlabel('Time')
ylabel('Phi (deg)')

figure(9)
plot(tplot,Q)
title('Dynamic Pressure vs Time')
xlabel('Time')
ylabel('Dynamic Pressure')

figure(10)
plot(y/1000,Q)
title('Dynamic Pressure vs. Altitude')
xlabel('Altitude')
ylabel('Dynamic Pressure')
