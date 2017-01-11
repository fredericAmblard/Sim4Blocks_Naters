% Initialization function
function s = system_init(model)
% returns a structure containing initial values, system parameters and
% state space matrices

% Structure of variables for simulink
s = struct;
% Model Name
M_name = model;

% time step use for simulation
step = get_param(M_name,'FixedStep');
if isnan(step)
    error('You must select a Fixed step solver !')
elseif strcmp(step,'auto')
    step = '1';
else
    step = str2double(get_param(M_name,'FixedStep'));
end
StartTime = str2double(get_param(M_name,'StartTime'));
StopTime = prod(str2double(strsplit(get_param(M_name,'StopTime'),'*')));
s.t = [StartTime:step:StopTime]';

%time = str2double(strsplit(get_param('NatersV4','StopTime'),'*'));
time = str2double(strsplit(get_param('NatersV4_cleanV2','StopTime'),'*'));
s.time = time;
if time(1) == 24 % hours
    sample_time = 3600;
elseif time(1) == 4 % 1/4 hours
    sample_time = 900;
elseif time(1) == 12 % 5 minutes
    sample_time = 300;
elseif time(1) == 60 % 1 minutes
    sample_time = 60;
elseif time(1) == 3600 % secondes
    sample_time = 1;
else
    error('The time sampling should be minutes, hours or day');
end
s.sample_time = sample_time;
%% Building

[s.Ab_c, s.Bb_c, s.Qdot_dem, Design] = get_state_input_mat_building(sample_time);

step=1/60;
% Continuous building model
s.Ab_c = s.Ab_c.*step;
s.Bb_c = s.Bb_c.*step;
sysb_c = ss(s.Ab_c, s.Bb_c, eye(size(s.Ab_c,1)), zeros(size(s.Ab_c,1), size(s.Bb_c,2)));
% impulsetest = impulse(sysb_c);
% 
% figure(1)
% impulse(sysb_c);
% [y, T] = impulse(sysb_c);
% 
% 
% tau1 = T(find(y(:,1,2)<=0.3678*y(1,1,2),1))/3600
% tau2 = T(find(y(find(y(:,2,1)>=max(y(:,2,1))):end,2,1)<=0.3678*max(y(:,2,1)),1))/3600
% tau3 = T(find(y(:,3,1)<=0.3678*y(1,3,1),1))/3600

% Discrete building model
sysb_d = c2d(sysb_c, 1);
[s.Ab_d, s.Bb_d] = ssdata(sysb_d);

% Vector of design parameters
s.Design = Design;

%% Heat pump model
[ K ] = get_param_hp(s.Qdot_dem);
s.k = K;
% Tprimary_in = repmat(linspace(-5,15,100),4,1); %[10 * ones(1,60),10 * ones(1,60)] ;
% Tsecondary_out = [35 * ones(1,100); 45* ones(1,100); 55* ones(1,100);65* ones(1,100)];%linspace(35,35,100);
% % 
% heating_power = K(1) * Tprimary_in + K(2) * Tsecondary_out + K(3); 
% electric_power = K(4) * Tprimary_in + K(5) * Tsecondary_out + K(6); 
% source_power = -K(7) * Tprimary_in - K(8) * Tsecondary_out - K(9);
% AA=heating_power+source_power-electric_power;
% plot(AA)
% figure(1)
% plot(Tprimary_in, heating_power(1,:),'r',Tprimary_in, heating_power(2,:),'b',Tprimary_in, heating_power(3,:),'g',Tprimary_in, heating_power(4,:),'y');
% hold on 
% plot(Tprimary_in, electric_power(1,:),'r',Tprimary_in, electric_power(2,:),'b',Tprimary_in, electric_power(3,:),'g',Tprimary_in, electric_power(4,:),'y');
% hold on 
% plot(Tprimary_in, -source_power(1,:),'r',Tprimary_in, -source_power(2,:),'b',Tprimary_in, -source_power(3,:),'g',Tprimary_in, -source_power(4,:),'y');
% COP = heating_power./electric_power;
% COP2 = 0.45*(273.15+Tsecondary_out)./ (Tsecondary_out-Tprimary_in);
% figure(2)
% plot(Tsecondary_out, COP,'-b', Tsecondary_out, COP2, 'r');

%% Other parameters and variables
% external temperature
% test temperature
% Text_data = load('Naters_Text.txt'); % test temperature vector
% s.Text = struct('time', s.t, 'signals', struct('values',Text_data(1:length(s.t),3)));
StartTime = 1;%24100*5;
%Sion data
Text_data = load('Sion_Temperatures_January_May_m'); % minute data
if sample_time ~= 1;
    Text_data = Text_data(StartTime:(sample_time/60):length(Text_data));
else
    Text_data = Text_data(StartTime:1:length(Text_data));
    Text_data = kron(Text_data,ones(60,1));
end
% test for design temperature
%Text_data = -10*ones(length(Text_data),1);

s.Text = struct('time', s.t, 'signals', struct('values',Text_data(1:length(s.t))));
Text_ini = s.Text.signals.values(1);

% room setpoint temperature 
Tin_sp_day = [18*ones(7,1);20*ones(16,1);18*ones(2,1)];
Tin_sp_vec = repmat(Tin_sp_day,ceil(length(s.t)/length(Tin_sp_day)),1);
s.Tin_sp = struct('time', s.t, 'signals', struct('values',Tin_sp_vec(1:length(s.t))));

% variable room temperature
Tin_sp = s.Tin_sp.signals.values(1);

% solar radiation
rad_90_data = load('Sion_Meteonorm_Radiation_SOUTH_90_January_May_m');
if sample_time ~= 1;
    rad_90 = rad_90_data(1:sample_time/60:length(rad_90_data));
else
    rad_90 = rad_90_data(1:sample_time:length(rad_90_data));
    rad_90 = kron(rad_90,ones(60,1));
end
s.rad_90 = struct('time', s.t, 'signals', struct('values', rad_90(1:length(s.t))));

% initial conditions
s.HP_status = 0;
s.L_ini = (s.Design(2)-Text_ini)/(s.Design(2)-s.Design(1));


end