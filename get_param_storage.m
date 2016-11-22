function [C_tes_top, C_tes_bot, K_sta_1, K_sta_2, K_l, C_w_hp, C_w_fh, mc_w, K_wa_fh, K_wa_hp] = get_param_storage(building_ID)
%GET_PARAM_STORAGE returns the thermal storage parameters of the selected building
%building = ['Naters1', 'Naters2'];
%switch building(building_ID)
%    case 'Naters1'
        cp_w = 4185;            % specific heat of water [J/kgK]
        rho_w = 1000;           % density of water [kg/m3]
        V1 = 0.5;               % Volume of upper layer of storage tank [m3]
        V2 = 1;                 % Volume of upper layer of storage tank [m3] 
        V_w_hp = 0.05;          % Volume of water in distribution system (HP) [m3]
        V_w_fh = 0.228;          % Volume of water in distribution system (floor heating) [m3]
        Acs = 3.141;            % cross section storage tank [m2] 2*pi*r = pi (r=0.5)
        dz_1 = 0.63;            % height of upper layer [m]
        dz_2 = 1.27;            % height of lower layer [m]
        k_w = 0.65;             % thermal conductivity of water (at 20°C) [W/mK]
        U_wa = 11.7;            % heat transfer coefficient between floor and room [W/m2K]
        % \--> Source: On the heat transfer coefficients between heated/cooled radiant floorand room Tomasz Cholewaa
        U_sta = 1.119;          % heat transfer coefficient of the storage tank wall [W/m2K]
        U_ra = 1.86;            % heat transfer coefficient of the wall [W/m2K]
        A_wa_fh = 200;          % floor heating pipes surface [m2]
        A_wa_hp = 200;          % pipes surface HP to storage[m2]
        A_ra = 326.4;           % wall surface [m2] 2*2.4H*(6l + 8L)=67.2
        K_ra = U_ra * A_ra;     % thermal conductance of the wall [W/K]
        K_l = Acs * k_w /(0.5 * (dz_1 * dz_2)); % thermal conductance between storage layers [W/K]
        K_wa_fh = U_wa * A_wa_fh;     % thermal conductance of the distribution pipes (hp) [W/K]
        K_wa_hp = U_wa * A_wa_hp;     % thermal conductance of the distribution pipes ([W/K]
        K_sta_1 = U_sta * Acs * dz_1; % thermal conductance between upper storage layer and outside [W/K]
        K_sta_2 = U_sta * Acs * dz_2; % thermal conductance between lower storage layer and outside [W/K]
%end

C_tes_top = cp_w * rho_w * V1;  % thermal capacity of upper layer of storage [J/K]
C_tes_bot = cp_w * rho_w * V2;  % thermal capacity of lower layer of storage [J/K]
C_w_hp = cp_w * rho_w * V_w_hp; % thermal capacity of water in distribution system (HP) [J/K]
C_w_fh = cp_w * rho_w * V_w_fh; % thermal capacity of water in distribution system (floor heating) [J/K]

% Design hydronic system, rules Karlsson_and_Fahlen_2008
Text_D = -10;                   % Design outdoor temperature [K] 
Tin_D = 20;                     % Design outdoor temperature [K] 
Ts_D = 35;                      % Design supply temperature [K]  
Tr_D = 28;                      % Design return temperature [K]
Q_D = K_ra * (Tin_D - Text_D);  % Design heat demand [W]
mc_w = Q_D / (Ts_D - Tr_D);     % Design thermal capacity flow [W/K]
tau_HP =3*60;                   % Time constant Heat Pump [s]
C_ws = tau_HP * mc_w;           % thermal capacity supply water [J/K]
C_w_fh = C_w_fh - C_ws;  