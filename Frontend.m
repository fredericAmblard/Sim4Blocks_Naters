% M_file to run Simulink model
clear;
%% Simulation parameter
Flag = 1; % flag 0 = off; 1 = on
StartTime = 1;
Nb_step = 24*10;
sample_time = 60; % [s]
Step = 1;
Nb_run = 1;
StopTime = strcat(num2str(sample_time),'*', num2str(Nb_step/Nb_run));
t = [StartTime:Step:(StartTime-1+sample_time*Nb_step/Nb_run)]';

%% Building
% Vector of design parameters
[Ab_c, Bb_c, Qdot_dem, Design] = get_state_input_mat_building(sample_time);

% Continuous building model
step=1/sample_time;
Ab_c = Ab_c.*step;
Bb_c = Bb_c.*step;
sysb_c = ss(Ab_c, Bb_c, eye(size(Ab_c,1)), zeros(size(Ab_c,1), size(Bb_c,2)));
% impulsetest = impulse(sysb_c);
% 
% figure(1)
% impulse(sysb_c);
% [y, T] = impulse(sysb_c);
% 
% tau1 = T(find(y(:,1,2)<=0.3678*y(1,1,2),1))/3600
% tau2 = T(find(y(find(y(:,2,1)>=max(y(:,2,1))):end,2,1)<=0.3678*max(y(:,2,1)),1))/3600
% tau3 = T(find(y(:,3,1)<=0.3678*y(1,3,1),1))/3600

% Discrete building model
sysb_d = c2d(sysb_c, 1);
[Ab_d, Bb_d] = ssdata(sysb_d);

%% Heat pump model
[ K ] = get_param_hp(Qdot_dem);
k = K;
% Tprimary_in = repmat(linspace(-5,15,100),4,1); %[10 * ones(1,60),10 * ones(1,60)] ;
% Tsecondary_out = [35 * ones(1,100); 45* ones(1,100); 55* ones(1,100);65* ones(1,100)];%linspace(35,35,100);
% Tprimary_in = repmat([2 10 15],4,1); %[10 * ones(1,60),10 * ones(1,60)] ;
% p = size(Tprimary_in,2);
% Tsecondary_out = [35 * ones(1,p); 45*ones(1,p); 55*ones(1,p); 60*ones(1,p)];%linspace(35,35,100);
% 
% heating_power = [K(1,1) * Tprimary_in(1:2,1:p) + K(1,2) * Tsecondary_out(1:2,1:p) + K(1,3); K(2,1) * Tprimary_in(3:4,1:p) + K(2,2) * Tsecondary_out(3:4,1:p) + K(2,3)];
% electric_power = [K(1,4) * Tprimary_in(1:2,1:p) + K(1,5) * Tsecondary_out(1:2,1:p) + K(1,6); K(2,4) * Tprimary_in(3:4,1:p) + K(2,5) * Tsecondary_out(3:4,1:p) + K(2,6)]; 
% source_power = [-K(1,7) * Tprimary_in(1:2,1:p) - K(1,8) * Tsecondary_out(1:2,1:p) - K(1,9); -K(2,7) * Tprimary_in(3:4,1:p) - K(2,8) * Tsecondary_out(3:4,1:p) - K(2,9)];
% % AA=heating_power+source_power-electric_power;
% % plot(AA)
% figure(1)
% plot(Tprimary_in(1,:), heating_power(1,:)/1000,'r',Tprimary_in(1,:), heating_power(2,:)/1000,'b',Tprimary_in(1,:), heating_power(3,:)/1000,'g',Tprimary_in(1,:), heating_power(4,:)/1000,'k');
% hold on 
% plot(Tprimary_in(1,:), -source_power(1,:)/1000,'*-r',Tprimary_in(1,:), -source_power(2,:)/1000,'*-b',Tprimary_in(1,:), -source_power(3,:)/1000,'*-g',Tprimary_in(1,:), -source_power(4,:)/1000,'*-k');
% hold on 
% plot(Tprimary_in(1,:), electric_power(1,:)/1000,'--r',Tprimary_in(1,:), electric_power(2,:)/1000,'--b',Tprimary_in(1,:), electric_power(3,:)/1000,'--g',Tprimary_in(1,:), electric_power(4,:)/1000,'--k');
% legend('Qhot [35°C]','Qhot [45°C]','Qhot [55°C]','Qhot [60°C]','Qcold [35°C]','Qcold [45°C]','Qcold [55°C]','Qcold [60°C]','E_el [35°C]','E_el [45°C]','E_el [55°C]','E_el [60°C]','Location','EastOutside');
% xlabel('Source temperature (Primary loop) [°C]');
% xlim([2 15])
% ylabel('Power [kW]');
% COP = heating_power./electric_power; 
% COP2 = 0.49*(273.15+Tsecondary_out)./ (Tsecondary_out-Tprimary_in);
% figure(2)
% %plot(Tsecondary_out, COP,'-b', Tsecondary_out, COP2, 'r');
% plot(Tprimary_in', COP','-b', Tprimary_in', COP2', 'r');

%% Other paramters and variables
% external temperature
%Sion data
Text_data = load('Sion_Temperatures_January_May_m'); % minute data
if sample_time ~= 1;
    Text_data = Text_data(StartTime:(sample_time/60):length(Text_data));
else
    Text_data = Text_data(StartTime:1:length(Text_data));
    Text_data = kron(Text_data,ones(60,1));
end
Text = struct('time', t, 'signals', struct('values',Text_data(1:length(t))));
Text_ini = Text.signals.values(1);
%clear Text_data

% room setpoint temperature 
Tin_sp_day = [18*ones(7,1);20*ones(16,1);18*ones(2,1)];
Tin_sp_vec = repmat(Tin_sp_day,ceil(length(t)/length(Tin_sp_day)),1);
Tin_sp = struct('time', t, 'signals', struct('values',Tin_sp_vec(1:length(t))));

% variable room temperature
Tin_sp = Tin_sp.signals.values(1);

% solar radiation
rad_90_data = load('Sion_Meteonorm_Radiation_SOUTH_90_January_May_m');
if sample_time ~= 1;
    rad_90_data = rad_90_data(1:sample_time/60:length(rad_90_data));
else
    rad_90_data = rad_90_data(1:sample_time:length(rad_90_data));
    rad_90_data = kron(rad_90_data,ones(60,1));
end
rad_90 = struct('time', t, 'signals', struct('values', rad_90_data(1:length(t))));
%clear rad_90_data

% initial conditions
HP_status = 0;
L_ini = (Design(2)-Text_ini)/(Design(2)-Design(1));

T_primary=10;


%%
mdl = bdroot;

set_param(mdl, 'SolverType','Fixed-step','FixedStep',num2str(Step),...
          'LoadInitialState', 'off', 'SaveCompleteFinalSimState', 'on',...
          'FinalStateName', [mdl 'xFinal']);

%[t1, Y1] = 
resul = sim(mdl, 'StopTime',StopTime,'StartTime',num2str(StartTime));
%plot(t1,Y1,'b');
%aa=resul.get([mdl 'SimState']);

% StartTime = StopTime;
% StopTime = strcat(num2str(sample_time),'*', num2str(Nb_step));
% %t = [(sample_time*Nb_step/2):Step:(StartTime-1+sample_time*Nb_step/2)]';
% t = [str2num(StartTime):Step:str2num(StopTime)]';
% Text = struct('time', t, 'signals', struct('values',Text_data((t(1):(t(1)+length(t))-1))));
% rad_90 = struct('time', t, 'signals', struct('values', rad_90_data((t(1):(t(1)+length(t))-1))));
% Text_ini = Text.signals.values(1);
% % t_pause = t_pause +50;
% 
% % set_param(mdl, 'LoadInitialState', 'on', 'InitialState',...
% % [mdl 'SimState']);
% 
% assignin('base', 'xFinal', resul.get([mdl 'xFinal']));
% set_param(mdl, 'SaveFinalState', 'off', ...
%           'LoadInitialState', 'on', 'InitialState', 'xFinal');
% T_primary=12;
% out1 = sim(mdl, 'StopTime',StopTime);
% set_param(mdl, 'LoadInitialState', 'off', 'InitialState',...
%  [mdl 'xFinal']);
% %[t2, Y2] = sim(mdl, 'StopTime',StopTime,'StartTime',num2str(StartTime));
% % resul2= sim(mdl, 'StopTime',StopTime,'StartTime',num2str(StartTime));
% %hold on; 
% %plot(t2,Y2,'r');
% set_param(mdl, 'LoadInitialState', 'off');








%%
% sim('NatersV4_cleanV2','SolverType','Fixed-step','StopTime',StopTime,'StartTime',num2str(StartTime),'FixedStep',num2str(Step),...
%     'SaveState','on','StateSaveName','xout', 'SaveOutput','on','OutputSaveName','yout','SaveFormat', 'Dataset');
% set_param('NatersV4_cleanV2', 'SimulationCommand', 'pause')
% % StartTime = StopTime;
% % StopTime = strcat(num2str(sample_time),'*', num2str(Nb_step));
% % t = [(sample_time*Nb_step/2/Nb_run):Step:(StartTime-1+sample_time*Nb_step/2)]';
% % Text = struct('time', t, 'signals', struct('values',Text_data((t(1):(t(1)+length(t))))'));
% % rad_90 = struct('time', t, 'signals', struct('values', rad_90_data((t(1):(t(1)+length(t))))'));
% % Text_ini = Text.signals.values(1);
% T_primary=12;
% t_pause = t_pause +50;
% % Find all blocks of type 'Constant', with the name 'Constant1'.
% 
% foundBlock = find_system(gcb, 'BlockType', 'Constant', 'Name', 'time_pause');
% % List the possible parameters for the found block. This step is only done
% % to identify the name of the parameter that needs to be changed when you don't
% % know for sure what the correct spelling might be.
% % foundBlock is a cell array.
% objParams = get_param(foundBlock{1}, 'ObjectParameters');
% % After identifying the parameter 'Value', proceed to change it.
% set_param(foundBlock{1}, 'Value', 't_pause');
% 
% %num2str(t_pause)
% %set_param('NatersV4_cleanV2','t_pause',t_pause);
% set_param('NatersV4_cleanV2', 'SimulationCommand', 'continue')
% % sim('NatersV4_cleanV2','SolverType','Fixed-step','StopTime',StopTime,'StartTime',num2str(StartTime),'FixedStep',num2str(Step),...
% %     'SaveState','on','StateSaveName','xout', 'SaveOutput','on','OutputSaveName','yout','SaveFormat', 'Dataset');
% % %set_param('NatersV4_cleanV2', 'SimulationCommand', 'continue')
% %set_param('NatersV4_cleanV2', 'SimulationCommand', 'pause')