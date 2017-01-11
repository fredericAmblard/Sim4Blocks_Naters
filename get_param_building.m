function [C_wr, mc_f, C_r, mdot_d_w, K_wf, K_fr, K_ra, cp_w, Q_D, Design] = get_param_building()
%GET_PARAM_BUILDING returns the parameters of the selected building

cp_w = 4185;        % specific heat of water [J/kgK]
rho_w = 1000;       % density of water [kg/m3]
rho_air = 1.204;    % density of air [kg/m3]
U_wf = 48;          % heat transfer coefficient of the distribution pipes [W/m2K] %48.2;
U_fr = 11.7;        % heat transfer coefficient between floor and room [W/m2K]
% \--> Source: On the heat transfer coefficients between heated/cooled radiant floorand room Tomasz Cholewaa
U_ra = 0.8;        % heat transfer coefficient of the wall [W/m2K] 1.19
A_fr = 350;         % floor surface [m2]
A_ra = 1080;         % wall surface [m2] 2*2.4H*(6l + 8L)=67.2
d_pipes = 0.013;   % internal diameter of the pipes [m]
d_dz = 0.2;        % space between the pipes [m]
L_pipes = A_fr/d_dz;    % length of the pipe [m]
A_wf = pi*d_pipes*L_pipes; % floor heating pipes surface [m2]
V_w = A_wf*d_pipes/4;      % Volume of water in distribution system [m3]0.228;
V_b = 6300;          % heated volume [m3]
K_wf = U_wf * A_wf; % thermal conductance of the distribution pipes [W/K]
K_fr = U_fr * A_fr; % thermal conductance between floor and room [W/K]
K_ra = U_ra * A_ra; % thermal conductance of the wall [W/K]
tau_r = 10;% 2.4
mc_f = 420e5;       % thermal capacity of the floor [J/K]

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
mdot_d_w = Q_D / ((Ts_D - Tr_D)*cp_w);     % Design mass flow [kg/s]
tau_HP =3*60;                   % Time constant Heat Pump [s]
C_ws = tau_HP * mdot_d_w * cp_w;           % thermal capacity supply water [J/K]
C_wr = C_w; %(C_w - C_ws)*10;        % thermal capacity return water [J/K]
