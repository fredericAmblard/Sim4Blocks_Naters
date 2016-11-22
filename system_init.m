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
time = str2double(strsplit(get_param('NatersV4_clean','StopTime'),'*'));
s.time = time;
if time(1) == 1
    sample_time = 24*60;
elseif time(1) == 24 % hours
    sample_time = 60;
elseif time(1) == 4 % 1/4 hours
    sample_time = 15;
elseif time(1) == 12 % 5 minutes
    sample_time = 5;
elseif time(1) == 60 % 1 minutes
    sample_time = 1;
else 
    error('The time sampling should be minutes, hours or day');
end
s.sample_time = sample_time;
%% Building
s.building = 'Naters1';
%number of state in building
nxb = 3;
% Continuous building model
[s.Ab_c, s.Bb_c, s.Qdot_dem, s.facHP, nb, K, Design] = get_state_input_mat_building(s.building , 'h');

s.Ab_c = s.Ab_c.*step;
s.Bb_c = s.Bb_c.*step;
sysb_c = ss(s.Ab_c, s.Bb_c, eye(nxb), zeros(nxb, size(s.Bb_c,2)));
%impulsetest = impulse(sysb_c);

time_unit =1;
% Discrete building model
sysb_d = c2d(sysb_c, 1);
[s.Ab_d, s.Bb_d] = ssdata(sysb_d);

% Vector of design parameters
s.Design = Design;


%% Heat pump model
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
%% Storage

%% Ground
% nxg = 12;
% % Continuous building model
% [s.Ag_c, s.Bg_c] = get_state_input_mat_ground(nxg , 'h', 'W');
% 
% s.Ag_c = s.Ag_c.*step;
% s.Bg_c = s.Bg_c.*step;
% s.Bg_c(1,1) = s.Bg_c(1,1)/nb; % Qground = u4
% sysg_c = ss(s.Ag_c, s.Bg_c, eye(nxg), zeros(nxg, size(s.Bg_c, 2)));
% 
% % Discrete building model
% sysg_d = c2d(sysg_c, 1);
% [s.Ag_d, s.Bg_d] = ssdata(sysg_d);

%% Other paramters and variables
% external temperature
% test temperature
% Text_data = load('Naters_Text.txt'); % test temperature vector
% s.Text = struct('time', s.t, 'signals', struct('values',Text_data(1:length(s.t),3)));
StartTime = 23100*5;
%Sion data
Text_data = load('Sion_Temperatures_January_May_m'); % minute data
Text_data = Text_data(StartTime:sample_time:length(Text_data));
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

%undisturbed ground temperature
%s.Tsoil = str2double(get_param('Naters/ground_temperature','Value'));

% solar radiation
rad_90_data = load('Sion_Meteonorm_Radiation_SOUTH_90_January_May_m');
rad_90 = rad_90_data(1:sample_time:length(rad_90_data));
s.rad_90 = struct('time', s.t, 'signals', struct('values', rad_90(1:length(s.t))));

% initial conditions
s.Tb_ini = get_ini_state_building(Tin_sp, Text_ini, s.building);
s.HP_status = 0;
s.L_ini = (s.Design(2)-Text_ini)/(s.Design(2)-s.Design(1));


end