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
