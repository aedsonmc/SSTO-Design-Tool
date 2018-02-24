%% AEE480 VARDA Project Propulsion Model
% Created by: Alex Edson
% Version date: Jan 24, 2018
% Values Obtained via CEARun, a NASA program

%% Purpose
% This code takes an input range of desired total thrust and outputs
% required flow rates for both fuel and oxidizers. This code consideres
% high purity LOX and intake air as useable oxidizers. It also will
% consider inlet areas, precooler load, BPR and OPR for the compressor
% section and the bypass burners. 

%% To-DOs
% --Need to consider number of engines
% --Write snippet to determine how much liquid air we can store or how much
%       liquid oxygen can be extracted and stored during ascent phase of flight
%       based on altitude. (Integrate into atmosphere.m)
% --Configure file to run as function (for future use and development)
% --Determine Bypass Ratio and Overall Pressure Ratio from inlet mass flow.
%       Include plots of relation of inlet area.
% --Determine Precooler surface area and heat load.
% --Determine power requirements for fuel/oxidizer pumps and helium loop
%

%% Main
%LOX Variables
OF_LOX = 5;
gamma_LOX = 1.25; %At nozzle exit
a_LOX = 1122.9; %m/s speed of sound
Me_LOX = 3.563; %Mach Number at exit
Ve_LOX = Me_LOX * a_LOX;

%Air Variables
OF_Air = 22;
gamma_Air = 1.32; %at nozzle exit
a_Air = 605.2; %m/s speed of sound
Me_Air = 3.696; %Mach Number at exit
Ve_Air = Me_Air * a_Air;

%Thrust Range Input
T = linspace(8.5e5,2e6,1000);

%Calculate Reqired Exit Mass Flow
m_dot_Exit_LOX = T./Ve_LOX;
m_dot_Exit_Air = T./Ve_Air;

%Calculate Oxidizer and Fuel Mass Flow Rates
m_dot_F_LOX = m_dot_Exit_LOX./OF_LOX;
m_dot_F_Air = m_dot_Exit_Air./OF_Air;
m_dot_Ox_LOX = m_dot_Exit_LOX - m_dot_F_LOX;
m_dot_Ox_Air = m_dot_Exit_Air - m_dot_F_Air;

%Plot Required Flow Rates
figure(1)
plot(T,m_dot_Exit_LOX,T,m_dot_Exit_Air)
title('Exit Mass Flow')
xlabel('Thrust')
ylabel('Mass Flow Rate (kg/s)')
grid on
legend('LOX','Air','location','NorthWest')

figure(2)
plot(T,m_dot_Ox_LOX,T,m_dot_Ox_Air)
title('Oxidizer Mass Flow')
xlabel('Thrust')
ylabel('Mass Flow Rate (kg/s)')
grid on
legend('LOX','Air','location','NorthWest')

figure(3)
plot(T,m_dot_F_LOX,T,m_dot_F_Air)
title('Fuel Mass Flow')
xlabel('Thrust')
ylabel('Mass Flow Rate (kg/s)')
grid on
legend('LOX','Air','location','NorthWest')