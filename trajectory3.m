%% AEE480 VARDA Project Trajectory Solver
% Created by: Alex Edson
% Version date: Mar 12, 2018
% Values allowing calculation of OF ratios and thrust Obtained via CEARun,
% a NASA program.

%% Purpose
% This code takes a series of inputs and iteratively solves for spacecraft
% position in an x-y frame. This will be changed to calculate PQW state vectors in the future.

%% To-DOs
% -Make function for accleration due to gravity with altitude
% -Make throttle function for mass flow and thrust
% -Use a controller (transfer function?) for changing Phi
% -Convert x and y into state vector for spacecraft and apply orbital
% mechanics
%% Main
clear,clc, close all

%Initialize Variables
g = 9.81;   %accleration due to gravity
m0 = 325000; %Initial Mass
mdot = 34.49; %mass flow for thrust. Will add throttleable settings based on chamber pressure and O/F ratios. For now thrust is constant
F = 1.6794e6; %maximum mass flow-based thrust
simTime = 800; %Simulation Time in Seconds
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
err = zeros(totalIterations,1,'gpuArray');
forcetail = zeros(totalIterations,1,'gpuArray');
m(1) = m0;
load('denprofile.mat') %to reduce call time on rho function
load('CD_no_nacelles.mat')
load('CL_no_nacelles.mat')
% dentemp = importdata('densityProfile.csv',','); %import density profile
% rho = @(a) interp1(dentemp(:,1),dentemp(:,2),a,'nearest');
click = 0;
K = 1;
%Iterate
for i = 2:totalIterations
   t = i*timestep;
   rhoi = rho(y(i-1),dentemp(:,:));
   CLi = CL(alpha(i-1),CLoutput(:,:));
   CDi = CD(alpha(i-1),CDoutput(:,:));
   ydotdot(i) = (F*sind(phi(i-1))+CLi*(0.5*rhoi*magu(i-1).^2*A)*cosd(phi(i-1))-CDi*(0.5*rhoi*magu(i-1).^2*A)*sind(theta(i-1))-m(i-1)*g-forcetail(i-1)*cosd(phi(i-1)))/m(i-1);
   ydot(i) = ydot(i-1) + ydotdot(i)*(timestep);
   y(i) = y(i-1) + ydot(i)*(timestep);
   xdotdot(i) = (F*cosd(phi(i-1))-CLi*(0.5*rhoi*magu(i-1).^2*A)*sind(phi(i-1))-CDi*(0.5*rhoi*magu(i-1).^2*A)*cosd(theta(i-1))+forcetail(i-1)*sind(phi(i-1)))/m(i-1);
   xdot(i) = xdot(i-1) + xdotdot(i)*(timestep);
   x(i) = x(i-1) + xdot(i)*(timestep);
   %controller
   if magu(i-1) <= 125
        phitgt = 5;
   elseif magu(i-1) > 125
        phitgt = 15;
   end
   if y(i) > 5000
       phitgt = 2;
       F = 2.75e6;
   end
   if y(i) > 50000
       phitgt = 60;
   end
   if y(i) > 1.3e5
       phitgt = 5;
       F = 0;
   end
   err(i) = err(i-1) + (phitgt - phi(i-1));
   forcetail(i) = K*err(i);
   phidotdot(i) = (forcetail(i) * 28) / 9e7;
   phidot(i) = phidot(i-1) + phidotdot(i-1)*timestep;
   phi(i) = phi(i-1) + phidot(i-1)*timestep;
   
   
   theta(i) = atand(ydot(i)/xdot(i));
   if y(i) < 50000
        m(i) = m(i-1) - mdot*timestep;
   elseif y(i) >= 50000
        m(i) = m(i-1) - mdot*timestep - 22*mdot*timestep;
   elseif F == 0
       m(i) = m(i-1);
   end
   if m(i) < 32500  %runs out of fuel
       m(i) = m(i-1);
       F = 0;
   end
   magu(i) = sqrt(xdot(i).^2+ydot(i).^2);
   magacc(i) = sqrt(xdotdot(i).^2 + ydotdot(i).^2);
   Q(i) = 0.5*rhoi*magu(i).^2;
   
   %takeoff fixing
   if magu(i) < 125
       phi(i) = 5;
       ydotdot(i) = 0;
       ydot(i) = 0;
       y(i) = 0;
   end
% 
%    %Climb Section
%    if magu(i) >= 125
%       phi(i) = 10;
%        if (y(i) >= 12500 && click == 0)
%            phi(i) = 2;
%            phidotdot(i) = 0;
%        end
%        if (magu(i) >= 6000 && click == 0)
%            phi(i) = 15;
%            F = 2.75e6;
%            click = 1;
%        end
%        if (y(i) >= 80000 && click == 1)
%            F = 0;
%            m(i) = m(i-1);
%            
%        end
%    end
%    if y(i) >= 1.3e5
%        m(i) = m(i-1);
%        F = 0;
%    end
%    if magu(i) < 7796
%        if y(i) >= 3.99e5
%            F = 3e5;
%            m(i) = m(i-1) - mdot*0.1*timestep - 22*mdot*0.1*timestep;
%            phi(i) = -0.5;
%        end
%        if y(i) >= 4e5
%            F = 0;
%            m(i) = m(i-1);
%            phi(i) = 0;
%        end
%    end
   alpha(i) = phi(i) - atand(ydot(i)/xdot(i));
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
plot(magu,m)
title('Mass vs Velocity')
xlabel('Velocity')
ylabel('Mass (kg)')

figure(7)
plot(tplot,y/1000)
title('Altitude vs Time')
xlabel('Time')
ylabel('Altitude (km)')

figure(8)
plot(tplot,magu)
title('Velocity vs Time')
xlabel('Time')
ylabel('Velocity (m/s)')

figure(9)
plot(tplot,phi)
title('Phi vs Time')
xlabel('Time')
ylabel('Phi (deg)')

figure(10)
plot(tplot,Q)
title('Dynamic Pressure vs Time')
xlabel('Time')
ylabel('Dynamic Pressure')

figure(11)
plot(y/1000,Q)
title('Dynamic Pressure vs. Altitude')
xlabel('Altitude')
ylabel('Dynamic Pressure')

figure(12)
plot(tplot,magacc/g)
title('Accerlation Normalized to g0')
xlabel('Time')
ylabel('Accelerations (g)')

figure(13)
plot(tplot,mach)
title('Mach Number vs Time')
xlabel('Time')
ylabel('Mach Number')

figure(14)
plot(tplot,forcetail)
title('Tail Force')
xlabel('Time')
ylabel('Force')
