%% AEE480 Varda Project
%Alex Edson
%Reentry Heating Code
%Source: First Order Solution from Lt. Col. Kerry D Hicks book assuming
%Shallow Angle Gliding Entry

clear,clc,close all
%% Variables
g0 = 9.81./1000; %standard gravity in km/s^2
r0 = 6378+400; %initial radius of orbit
alt = linspace(0,400,1000);  %above earth, km
beta = 0.14; % km^-1  Some exponential atmosphere constant
rho_s = 1.225; %kg/m^3 surface density
rho = @(a) rho_s*exp(-beta*a); %density at altitude using exponential atmosphere model. Altitude in km.
ldratio = 4; %lift to drag ratio. Need to apply value from CFD.
CD = 0.15; %guessing here for CD. Need to apply value from CFD.
S = 687; %Reference area in m^2
V0 = sqrt(g0*r0); %initial circular orbital velocity, km/s
m = 45000; %mass of vehicle in kg
eta = @(h) ((rho_s*S*CD)/(2*m*(beta/1000)))*exp((-beta/1000)*(h)); %non dimensional altitude, h in meters
Tndcalc = @(V) (1/2)*((V.^2)/(g0*r0)); %Vehicle kinetic energy
Vndcalc = @(V) V/V0; %non-dimensional velocity related to inital orbital velocity
for i=1:length(alt)
   altnd(i) = beta*r0*eta(alt(i)*1000); %non dimensional altitude
end
%% Calculate Stuff
for i=1:length(alt)
    V(i) = sqrt((g0*r0)/(1+beta*r0.*eta(alt(i)*1000)*ldratio)); %m/s
    Vnd(i) = Vndcalc(V(i)); %non dimensional velocity
    T(i) = Tndcalc(V(i)); %non dimensional kinetic energy
    enValt(i) = 1/(2*(1+beta*r0.*eta(alt(i)*1000)*ldratio)); %kinetic energy related to altitude
    velValt(i) = 1/(1+beta*r0.*eta(alt(i)*1000)*ldratio); %Velocity vs Altitude (V^2/g0r0)
    gamma(i) = (-1/(ldratio*beta*r0*T(i))); %flight path angle 
    decelnd(i) = (1-2*T(i))/ldratio;

end

%% Plot Stuff
figure(1)
semilogy(enValt,altnd)
title('Altitude/Energy Relationship')
xlabel('Non-Dimensional Kinetic Energy')
ylabel('\betar_0\eta')

figure(2)
semilogy(Vnd,altnd)
title('Altitude/Velocity Relationship')
xlabel('V/V_0')
ylabel('\betar_0\eta')

figure(3)
plot(Vnd,gamma)
title('Flight Path Angle vs Velocity')
xlabel('V/V_0');
ylabel('Flight Path Angle (rad)')
axis([0 1 -0.5 0])

figure(4)
plot(V*1000,alt)
title('Velocity/Altitude Relationship, not log')
xlabel('Velocity (m/s)')
ylabel('Altitude (km)')

figure(5)
plot(decelnd,alt)
title('Deceleration vs Altitude')
ylabel('Altitude')
xlabel('Deceleration')
