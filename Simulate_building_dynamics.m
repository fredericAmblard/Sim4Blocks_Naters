function [Tb_out, Qdem]  = Simulate_building_dynamics(Tb_in , Text, Gin, Psol, Tws, flow_fraction,sample_time)
%#codegen
% Twr   : Return temperature of the heating system
% Tf    : Temperature of floor
% Tr    : Temperature of the room

% state matrix x = [Twr, Tf, Tin]';
% input matrix u = [Text, Tws, Gin, Psol]'

[Ab_d, Bb_d,K_fr, K_wf,K_ra, C_wr, mc_f, thermal_capacity_flow] = get_state_input_mat_building(flow_fraction,sample_time);

% F, L,
%Tws = 35;

%Tb_out = Ab_d * Tb_in + Bb_d * [Text; Qsup; Gin; Psol];
Tb_out = Ab_d * Tb_in + Bb_d * [Text; Tws; Gin; Psol];
%Qdem = K_fr * (Tb_out(2)-Tb_out(3));

% Qdem2 = K_fr * (Tb_in(1)-Tb_in(2));
Qdem = K_ra * (Tb_in(3)-Text)-Psol-Gin;
%Qdem = K_wf * (Tb_out(1)-Tb_out(2));
%Qsup = FH_st * mc_w * (Tws-Tb_out(1));
% Qsup = K_wf * (Tb_out(1)-Tb_out(2));
% Qin = mc_f * (Tb_in(2)-Tb_out(2))/(60/time_u*60);
% test = (Qdem + Qsup) - Qin;
end

function [Ab_d, Bb_d, K_fr,K_wf,K_ra, C_WH, C_floor, thermal_capacity_flow, Qdot, facHP, nb] = get_state_input_mat_building(floor_heating_flow_fraction, sample_time)

% Create the state matrix and the input matrix for the building system

% state vector for the building
% x_b = [Twr, Tf, Tin]'

% input vector for the building
% u_b = [Text, Tws, Qaux]

[C_WH, C_floor, C_room, thermal_capacity_flow, K_wf, K_fr, K_ra, cp_w, Qdot, L_pipes] = get_param_building();
mw_dot = thermal_capacity_flow * floor_heating_flow_fraction;

% Fourier number
Fo_1 = (K_fr*0.1*sample_time)/C_floor;
Fo_2 = (K_wf*L_pipes*sample_time)/C_WH;


% A = [...
% [ -(K_wf + 3*cp_w*mw_dot)/C_return,                                0,         (3*cp_w*mw_dot)/C_return,                  K_wf/C_return,                     0];
% [                                0, -(K_wf + 3*cp_w*mw_dot)/C_return,                                0,                  K_wf/C_return,                     0];
% [                                0,         (3*cp_w*mw_dot)/C_return, -(K_wf + 3*cp_w*mw_dot)/C_return,                  K_wf/C_return,                     0];
% [                 K_wf/(2*C_floor),                 K_wf/(2*C_floor),                                0, -(2*K_fr + 2*K_wf)/(2*C_floor),          K_fr/C_floor];
% [                                0,                                0,                                0,                    K_fr/C_room, -(K_fr + K_ra)/C_room] ...
% ];

A = [...
[ -(K_fr + 3*K_wf)/C_floor,                   K_wf/C_floor,                   K_wf/C_floor,                   K_wf/C_floor,          K_fr/C_floor]
[            (3*K_wf)/C_WH, -(3*(K_wf + cp_w*mw_dot))/C_WH,                              0,                              0,                     0]
[            (3*K_wf)/C_WH,           (3*cp_w*mw_dot)/C_WH, -(3*(K_wf + cp_w*mw_dot))/C_WH,                              0,                     0]
[            (3*K_wf)/C_WH,                              0,           (3*cp_w*mw_dot)/C_WH, -(3*(K_wf + cp_w*mw_dot))/C_WH,                     0]
[              K_fr/C_room,                              0,                              0,                              0, -(K_fr + K_ra)/C_room]...
];

% B = [...
% [           0,                        0,        0,        0];
% [           0, (3*cp_w*mw_dot)/C_return,        0,        0];
% [           0,                        0,        0,        0];
% [           0,                        0,        0,        0];
% [ K_ra/C_room,                        0, 1/C_room, 1/C_room]...
% ];
B = [...
[           0,                    0,        0,        0]
[           0, (3*cp_w*mw_dot)/C_WH,        0,        0]
[           0,                    0,        0,        0]
[           0,                    0,        0,        0]
[ K_ra/C_room,                    0, 1/C_room, 1/C_room]...
];

Ab_d = expm(sample_time*A);
Bb_d = A\(Ab_d-eye(size(A, 1)))*B;

a=1;

end

function [C_wr, mc_f, C_r, mdot_d_w, K_wf, K_fr, K_ra, cp_w, Q_D,L_pipes] = get_param_building()
%GET_PARAM_BUILDING returns the parameters of the selected building

cp_w = 4185;        % specific heat of water [J/kgK]
rho_w = 1000;       % density of water [kg/m3]
rho_air = 1.204;    % density of air [kg/m3]
V1 = 0.4;               % Volume of upper layer of storage tank [m3]
V2 = 0.4;               % Volume of middle layer of storage tank [m3]
V3 = 0.4;               % Volume of lower layer of storage tank [m3]
U_wf = 11;          % heat transfer coefficient of the distribution pipes [W/m2K] %48.2;
U_fr = 11.7;        % heat transfer coefficient between floor and room [W/m2K]
% \--> Source: On the heat transfer coefficients between heated/cooled radiant floorand room Tomasz Cholewaa
U_ra = 0.8;        % heat transfer coefficient of the wall [W/m2K] 1.19
A_fr = 350;         % floor surface [m2]
A_ra = 1080;         % wall surface [m2] 2*2.4H*(6l + 8L)=67.2
d_pipes = 0.033;   % internal diameter of the pipes [m]
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

L_pipes = V_w/A_wf;

C_w = cp_w * rho_w * (V_w);%+V1+V2+V3);   % thermal capacity water [J/K]
%C_r = K_ra * tau_r;         % thermal capacity of the room [J/K]
C_r = V_b * rho_air * 1005 * tau_r; % thermal capacity of the room [J/K]
% Design hydronic system, rules Karlsson_and_Fahlen_2008
Text_D = -10;                   % Design outdoor temperature [K] 
Tin_D = 20;                     % Design outdoor temperature [K] 
Ts_D = 35;                      % Design supply temperature [K]  
Tr_D = 28;                      % Design return temperature [K]
Q_D = K_ra * (Tin_D - Text_D);  % Design heat demand [W]
mdot_d_w = Q_D / ((Ts_D - Tr_D)*cp_w);     % Design mass flow [kg/s]
v = mdot_d_w/(rho_w*(pi*(d_pipes^2)/4));   % Design velocity [m/s]
if v>1.2
    warning('The water velocity in the pipe is too high (noise"s problem are expected. Consider checking the diameter')
end
tau_HP =3*60;                   % Time constant Heat Pump [s]
C_ws = tau_HP * mdot_d_w * cp_w;           % thermal capacity supply water [J/K]
C_wr = C_w; %(C_w - C_ws)*10;        % thermal capacity return water [J/K]

end