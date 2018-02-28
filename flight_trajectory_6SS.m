%% AEE480 VARDA Project Flight Trajectory Tool
% Created by: Breydan Dotson
% Version date: February 20, 2018
clear,clc, close all

t0 = 0; tf = 60; % time span for ODE solver
% state variables z = [x, x_dot, y, y_dot, psy, psy_dot]
z0 = 0.1*ones(1,6); % initial conditions

[t,z] = ode45(@f,[t0, tf], z0); % call ODE solver

x = z(:,1); x_dot = z(:,2); y = z(:,3); y_dot = z(:,4); psy = z(:,5); psy_dot = z(:,6); % separate and plot state variables
u = sqrt(x_dot.^2+y_dot.^2); % find speed --> magnitude of velocity vectors
theta = atan(y_dot./x_dot); % determine direction of that speed

% plot
figure(1)
subplot(2,2,1)
plot(x,y)
xlabel('x position, m'); ylabel('y position, m'); grid on
subplot(2,2,2)
plot(t,u)
xlabel('time, s'); ylabel('speed, m/s'); grid on
subplot(2,2,3)
plot(t,psy*180/pi)
xlabel('time, s'); ylabel('thrust direction, degrees'); grid on
subplot(2,2,4)
plot(t,theta*180/pi)
xlabel('time, s'); ylabel('flight path angle, degrees'); grid on

%------------------------------------------------
function [ z_dot ] = f( t,z )

g = 9.8; % gravitational constant, m/s^2
A = 682; % wing area, approximation, m^2

% allow for cL or cD to be determined from ANSYS simulation data
% cL_data = importdata('CLoutput.csv',',');
% cD_data = importdata('CDoutput.csv',',');
% cL = @(a) interp1(cL_data(:,1),cL_data(:,2),a,'nearest');
% cD = @(a) interp1(cD_data(:,1),cD_data(:,2),a,'nearest');

% state space form of  - for notes on derivation, see memo
% recall z = [x, x_dot, y, y_dot, psy, psy_dot]
% u = sqrt(x_dot^2+y_dot^2)
% alpha = atand(y_dot/x_dot)
z_dot(1) = z(2);
z_dot(2) = (F(sqrt(z(2)^2+z(4)^2))*cos(z(5))-CL(atand(z(4)/z(2)))*1/2*rho(z(3))*(z(2)^2+z(4)^2)*A*sin(z(5))-CD(atand(z(4)/z(2)))*1/2*rho(z(3))*(z(2)^2+z(4)^2)*A*cos(atan(z(4)/z(2))))/m(t);
z_dot(3) = z(4);
z_dot(4) = (F(sqrt(z(2)^2+z(4)^2))*sin(z(5))+CL(atand(z(4)/z(2)))*1/2*rho(z(3))*(z(2)^2+z(4)^2)*A*cos(z(5))-CD(atand(z(4)/z(2)))*1/2*rho(z(3))*(z(2)^2+z(4)^2)*A*sin(atan(z(4)/z(2)))-m(t)*g)/m(t);
z_dot(5) = z(6);
z_dot(6) = 0;

z_dot = z_dot'; % needs to be transposed for ode45
end
