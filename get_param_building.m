function [C_wr, mc_f, C_r, mc_w, K_wf, K_fr, K_ra, Q_D, facHP, nb,K, Design] = get_param_building(building)
%GET_PARAM_BUILDING returns the parameters of the selected building
cp_w = 4185;        % specific heat of water [J/kgK]
rho_w = 1000;       % density of water [kg/m3]
rho_air = 1.204;    % density of air [kg/m3]
V_w = 0.188;        % Volume of water in distribution system [m3]0.228;
V1 = 0.4;               % Volume of upper layer of storage tank [m3]
V2 = 0.4;               % Volume of middle layer of storage tank [m3]
V3 = 0.4;               % Volume of lower layer of storage tank [m3]
U_wf = 48.2;          % heat transfer coefficient of the distribution pipes [W/m2K] %48.2;
U_fr = 11.7;        % heat transfer coefficient between floor and room [W/m2K]
% \--> Source: On the heat transfer coefficients between heated/cooled radiant floorand room Tomasz Cholewaa
U_ra = 0.8;        % heat transfer coefficient of the wall [W/m2K] 1.19
A_wf = 140;         % floor heating pipes surface [m2]
A_fr = 350;         % floor surface [m2]
A_ra = 1080;         % wall surface [m2] 2*2.4H*(6l + 8L)=67.2
V_b = 6300;          % heated volume [m3]
K_wf = U_wf * A_wf; % thermal conductance of the distribution pipes [W/K]
K_fr = U_fr * A_fr; % thermal conductance between floor and room [W/K]
K_ra = U_ra * A_ra; % thermal conductance of the wall [W/K]
tau_r = 10;% 2.4
mc_f = 4.2e5;       % thermal capacity of the floor [J/K]

C_w = cp_w * rho_w * (V_w);%+V1+V2+V3);   % thermal capacity water [J/K]
%C_r = K_ra * tau_r;         % thermal capacity of the room [J/K]
C_r = V_b * rho_air * 1005 * tau_r; % thermal capacity of the room [J/K]
% Design hydronic system, rules Karlsson_and_Fahlen_2008
Text_D = -10;                   % Design outdoor temperature [K] 
Tin_D = 20;                     % Design outdoor temperature [K] 
Ts_D = 35;                      % Design supply temperature [K]  
Tr_D = 28;                      % Design return temperature [K]
Q_D = K_ra * (Tin_D - Text_D);  % Design heat demand [W]
Design = [Text_D, Tin_D, Ts_D, Tr_D]; % Vector of design paramters
mc_w = Q_D / (Ts_D - Tr_D);     % Design thermal capacity flow [W/K]
tau_HP =3*60;                   % Time constant Heat Pump [s]
C_ws = tau_HP * mc_w;           % thermal capacity supply water [J/K]
C_wr = (C_w - C_ws);        % thermal capacity return water [J/K]

% Heat pump system sizing
beta_HP =0.8;
% inlet source temperature vector
Thp_source = [-5 15]; % [°C]
% outlet/sink temperature vector
Thp_sink = [35 45 55 65]; % [°C]

if(0 <= Q_D)  && (Q_D < 10e3)
    Q_cold = 1e3*[4.75 5 4.7 3.9; 9, 8.75 8.4 7.5]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[6.3 7.3 7.3 7.3; 11.1, 11.55, 11.55, 11.55]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[1.65, 2.3, 2.75, 3.4; 2.1, 2.8, 3.2, 4]; % Electric power matrix (compressor) [W]
elseif (10e3 <= Q_D)  && (Q_D < 29e3)
    Q_cold = 1e3*[14.8 14.1 13.2 11.6; 24.75, 23.3 22 20.4]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[24.9 24.9 24.9 24.9; 30.5, 30.5, 30.5, 30.5]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[5.75, 6.25, 7.1, 8.8; 5.95, 7.2, 8.75, 10.2]; % Electric power matrix (compressor) [W]
elseif (29e3 <= Q_D)  && (Q_D < 36e3)
    Q_cold = 1e3*[18.25 17.2 16 14.5; 31.3, 29.9 28.2 26.1]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[20.3 20.3 20.3 20.3; 38.9, 38.9, 38.9, 38.9]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[6.75, 7.75, 8.8, 10.4; 7.5, 9, 10.75, 12.8]; % Electric power matrix (compressor) [W]
end

A = [subsref(Q_hot.', substruct('()', {':'})),subsref(Q_cold.', substruct('()', {':'})), subsref(Pel.', substruct('()', {':'})), repelem(Thp_source,length(Thp_sink))', repmat(Thp_sink,1,2)']; 
K = hp_param(A);
Q_daikin = 5000;%Q_range_HP(Ts_D , 5);
facHP = beta_HP * Q_D / Q_daikin(end);
nb = beta_HP * Q_D / 5000;





% 
% cp_w = 4185;        % specific heat of water [J/kgK]
% rho_w = 1000;       % density of water [kg/m3]
% V_w = 0.228;        % Volume of water in distribution system [m3]
% U_wf = 88;          % heat transfer coefficient of the distribution pipes [W/m2K] 
% U_fr = 11.7;        % heat transfer coefficient between floor and room [W/m2K]
% % \--> Source: On the heat transfer coefficients between heated/cooled radiant floorand room Tomasz Cholewaa
% U_ra = 1.19;        % heat transfer coefficient of the wall [W/m2K] 1.86 (engineering toolbox 2 - 3.9 W/m2K) 
% A_wf = 240;         % floor heating pipes surface [m2]
% A_fr = 350;         % floor surface [m2]
% A_ra = 780;         % wall surface [m2] 2*2.4H*(6l + 8L)=67.2 326.4
% K_wf = U_wf * A_wf; % thermal conductance of the distribution pipes [W/K]
% K_fr = U_fr * A_fr; % thermal conductance between floor and room [W/K]
% K_ra = U_ra * A_ra; % thermal conductance of the wall [W/K]
% tau_r = 28 * 3600; % 
% mc_f = 420e6;       % thermal capacity of the floor [J/k]
% 
% C_w = cp_w * rho_w * V_w;   % thermal capacity water [J/K]
% C_r = K_ra * tau_r;         % thermal capacity of the room [J/K]
% 
% % Design hydronic system, rules Karlsson_and_Fahlen_2008
% Text_D = -10;                   % Design outdoor temperature [K] 
% Tin_D = 20;                     % Design outdoor temperature [K] 
% Ts_D = 35;                      % Design supply temperature [K]  
% Tr_D = 28;                      % Design return temperature [K]
% Q_D = K_ra * (Tin_D - Text_D);  % Design heat demand [W]
% Design = [Text_D, Tin_D, Ts_D, Tr_D]; % Vector of design paramters
% mc_w = Q_D / (Ts_D - Tr_D);     % Design thermal capacity flow [W/K]
% tau_HP =3*60;                   % Time constant Heat Pump [s]
% C_ws = tau_HP * mc_w;           % thermal capacity supply water [J/K]
% C_wr = C_w - C_ws;              % thermal capacity return water [J/K]
% 
% % Heat pump system sizing
% beta_HP =0.8;
% % inlet source temperature vector
% Thp_source = [-5 15]; % [°C]
% % outlet/sink temperature vector
% Thp_sink = [35 45 55 65]; % [°C]
% 
% if(0 <= Q_D)  && (Q_D < 10e3)
%     Q_cold = 1e3*[4.75 5 4.7 3.9; 9, 8.75 8.4 7.5]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[6.3 7.3 7.3 7.3; 11.55, 11.55, 11.55, 11.55]; % Source power matrix (evaporator) [W]
%     Pel = Q_hot-Q_cold;  % Electric power matrix (compressor) [W] 1e3*[1.65, 2.3, 2.75, 3.4; 2.1, 2.8, 3.2, 4];
% elseif (10e3 <= Q_D)  && (Q_D < 29e3)
%     Q_cold = 1e3*[14.8 14.1 13.2 11.6; 24.75, 23.3 22 20.4]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[20.5 20.5 20.5 20.5; 30.5, 30.5, 30.5, 30.5]; % Source power matrix (evaporator) [W]
%     Pel = Q_hot-Q_cold; % Electric power matrix (compressor) [W] 1e3*[5.75, 6.25, 7.1, 8.8; 5.95, 7.2, 8.75, 10.2];
% elseif (29e3 <= Q_D)  && (Q_D < 36e3)
%     Q_cold = 1e3*[18.25 17.2 16 14.5; 31.3, 29.9 28.2 26.1]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[20.3 20.3 20.3 20.3; 38.9, 38.9, 38.9, 38.9]; % Source power matrix (evaporator) [W]
%     Pel = Q_hot-Q_cold; % Electric power matrix (compressor) [W] 1e3*[6.75, 7.75, 8.8, 10.4; 7.5, 9, 10.75, 12.8];
% end
