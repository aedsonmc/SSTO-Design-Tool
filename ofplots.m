%% AEE480 VARDA Project: O/F Ratio Block
% Created by: Paul Gray
% Version date: Feb 9, 2018
% Requires MSISE90.txt to be in same directory to run properly

%%
%%% Initial values %%%
% Mach and area values to be tested
mach = [1, 2, 3, 4, 5, 6, 7, 8, 9];
area = [25, 30, 32.5, 35, 37.5, 40, 42.5, 45, 47.5];

% Sound speed, while it varies with height for simplication it's held
% constant
a = 343;
vel = a*mach;

% Fuel mass flow rate and O/F ratios, Stoich (ofs) and minimum (ofm)
fuel_mdot = 86;
ofs = 33;
ofm = 11;

% Subplot zoom factors, coarse and fine
zfxc = 2;
zfyc = 2;
zfxf = 5;
zfyf = 5;

% Atmospheric constants
p0 = 101325;        % Pa
cp = 0.0065;        % K/m
T0 = 1007;          % J/(kgK)
g = 9.807;          % m/s^2
M = 0.028964;       % kg/mol
R0 = 8.31447;       % J/(molK)
gamma = 1.4;

%%% MSIS-E-90 Model Data for Density %%%
% Data is imported as g/cm3 before conversion to kg/m3, taken with a height
% density of 100m
%-% Possibly interpolate data for ~10m density resolution
% Reference: https://omniweb.gsfc.nasa.gov/vitmo/msis_vitmo.html
msisdata = importdata('MSISE90.txt');
msisdata_kg = msisdata(:,2).*1000;
msis_alt = msisdata(:,1);

mr_alt = zeros(length(mach),length(area));

%% 
%%% Value determination and plotting loops for O/F vs Alt
for j = 1:length(mach)

    % Memory preallocation of loop arrays
    amdot = zeros(length(area),length(msisdata));
    of = zeros(length(area),length(msisdata));
    legendInfo1{1,length(area)} = [];

    % Loop for the determination of air mass flow rate and the resulting
    % O/F ratio, assuming all oxidizer is supplied by the air intake
    for i = 1:length(area)

        amdot(i,1:length(msisdata)) = msisdata_kg.*vel(j).*area(i);
        of(i,1:length(msisdata)) = amdot(i,:)./fuel_mdot;

    end

    % Plotting loop for the O/F ratio as a function of altitude
    % Subplot position 1 is the full plot, subplot position 2 is zoomed in
    % around the O/F = Stoich crossing area
    for i = 1:length(area)

       figure(j)
       subplot(1,2,1)
       hold on
       plot(msis_alt,of(i,:),'LineWidth',1.25)
       legendInfo1{i} = ['Area = ', num2str(area(i)),' m^{2}'];
       
       % Zoomed subplot 
       subplot(1,2,2)
       hold on
       plot(msis_alt,of(i,:),'LineWidth',1.25)      

       if i == length(area)
          % Determines central plotline then pulls O/F ~ Stoich from that line
          % before determining x and y limits from zoom factor
          mu = floor(length(area)/2);
          [b, index] = min(abs(of(mu,:) - ofs));
          
          % Variable zoom factor (coarse/fine) block
          if range(of(mu,:)) < 1000
              
              limit_xl = msis_alt(index) - range(msis_alt)/(zfxc*2);
              limit_xu = msis_alt(index) + range(msis_alt)/(zfxc*2);
              limit_yl = of(mu,index) - range(of(mu,:))/(zfyc*2);
              limit_yu = of(mu,index) + range(of(mu,:))/(zfyc*2);
          
          else
             
              limit_xl = msis_alt(index) - range(msis_alt)/(zfxf*2);
              limit_xu = msis_alt(index) + range(msis_alt)/(zfxf*2);
              limit_yl = of(mu,index) - range(of(mu,:))/(zfyf*2);
              limit_yu = of(mu,index) + range(of(mu,:))/(zfyf*2);
              
          end
          
          % Because we like our plot bounds to make sense
          if limit_yl <= 0
              
            limit_yl = 0;
              
          end
           
          % Finishing touches of the subplots
          subplot(1,2,1)
          grid on
          grid minor
          title(['O/F Ratio vs. Altitude w/ Varying Intake Areas @ Mach = ' ...
              , num2str(mach(j))])
          xlabel('Altitude [km]')
          ylabel('O/F Ratio')
          plot([msis_alt(1),msis_alt(end)],[ofs,ofs],'k--','LineWidth',1.15)
          plot([msis_alt(1),msis_alt(end)],[ofm,ofm],'r--','LineWidth',1.15)
          legendInfo1{i+1} = ['O/F = ', num2str(ofs),' Stoich'];
          legendInfo1{i+2} = ['O/F = ', num2str(ofm),' Min'];
          legend(legendInfo1)
          
          subplot(1,2,2)
          grid on
          grid minor
          xlabel('Altitude [km]')
          ylabel('O/F Ratio')
          plot([msis_alt(1),msis_alt(end)],[ofs,ofs],'k--','LineWidth',1.15)
          plot([msis_alt(1),msis_alt(end)],[ofm,ofm],'r--','LineWidth',1.15)
          xlim([limit_xl, limit_xu])
          ylim([limit_yl, limit_yu])
          legendInfo1{i+1} = ['O/F = ', num2str(ofs),' Stoich'];
          legendInfo1{i+2} = ['O/F = ', num2str(ofm),' Min'];
          legend(legendInfo1)
          
       end

    end

    % Finds the altitude at which the O/F ratio first drops below Stoich
    % values and stores in array for later plotting
    for i = 1:length(area)
        
        [d, index2] = min(abs(of(i,:) - ofs));
        mr_alt(j,i) = msis_alt(index2);
    
    end
    
end

%%
% Plotting Mach vs. R2
% There is an issue with having vector lengths properly match. Thus for now
% use the same number of Mach as Inlet Areas...

% Memory preallocation
legendInfo2{1,length(area)} = [];
legendInfo3{1,length(mach)} = [];

for i = 1:length(mach)
    
   figure(length(mach) + 1)
   subplot(1,2,1)
   hold on
   plot(mr_alt(i,:),mach,'LineWidth',1.25)
   legendInfo2{i} = ['Area = ', num2str(area(i)),' m^{2}'];
   
   subplot(1,2,2)
   hold on
   plot(mr_alt(:,i),area,'LineWidth',1.25)
   legendInfo3{i} = ['Mach = ', num2str(mach(i))];
   
   if i == length(mach)
       
       subplot(1,2,1)
       grid on
       grid minor
       title('Mach vs. Stoich O/F')
       xlabel('O/F = Stoich Altitude [km]')
       ylabel('Mach')
       xlim([0, max(msis_alt)])
       ylim([0, max(mach) + 1])
       lgd = legend(legendInfo2,'Location','northeast');
       title(lgd,'Combined Inlet Area')
       
       subplot(1,2,2)
       grid on
       grid minor
       title('Inlet Area vs. Stoich O/F')
       xlabel('O/F = Stoich Altitude [km]')
       ylabel('Inlet Area [m^{2}]')
       xlim([0, max(msis_alt)])
       ylim([min(area) - 5, max(area) + 5])
       lgd = legend(legendInfo3,'Location','northeast');
       title(lgd,'Mach')
     
   end   
       
end

%%
% Max Dynamic Pressure block (beginnings of...)
h = msis_alt.*1000;
p = p0.*exp((-1)*((g.*M.*h)./(R0.*T0)));
q = zeros(length(mach),length(p));

for i = 1:length(mach)
    
    q(i,:) = 0.5.*gamma.*p.*mach(i).^2;

end






