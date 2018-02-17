%% AEE480 VARDA Project Trajectory Solver
% Created by: Alex Edson
% Version date: Feb 16, 2018
% Values Obtained via CEARun, a NASA program

%% Purpose
% This code takes a series of inputs and iteratively solves for spacecraft
% position based on vector state space form equation.

%% To-DOs
% 
%

%% Main
clear,clc, close all

%Initialize Variables
m0 = 325000; %Initial Mass
mdot = 750; %mass flow for thrust. Will add throttleable settings based on chamber pressure and O/F ratios. For now thrust is constant
F = 1.6794e6; %maximum mass flow-based thrust
simTime = 60; %Simulation Time in Seconds
timestep = 0.001; %Simulation Time Step
totalIterations = simTime/timestep; %Number of Iterations
sref = 100; %m^2 reference area
x = zeros(totalIterations,1); %initialize solution matricies
u = zeros(totalIterations,1);
dudt = zeros(totalIterations,1);
y = zeros(totalIterations,1);
v = zeros(totalIterations,1);
dvdt = zeros(totalIterations,1);
theta = zeros(totalIterations,1);
dtheata = zeros(totalIterations,1);
dtheta2 = zeros(totalIterations,1);
thetatgt = zeros(totalIterations,1);
dentemp = importdata('densityProfile.csv',','); %import density profile
alt = dentemp(:,1);
density = dentemp(:,2);
%Insert Mass Flow Table here

%Iterate
