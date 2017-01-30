function [A, B, Q_Design, Design] = get_state_input_mat_building(sample_time)

% Create the state matrix and the input matrix for the building system

% state vector for the building
% x_b = [Tf, Twh1, Twh2, Twr, Tin]'

% input vector for the building
% u_b = [Text, Tws, Gin, Psol]';

[C_WH, C_floor, C_room, mw_dot, K_wf, K_fr, K_ra, cp_w, Q_Design, Design] = get_param_building();

%% State Matrix


A = [...
[ -(3*K_fr + 3*K_wf)/(3*C_floor),             K_wf/(3*C_floor),             K_wf/(3*C_floor),             K_wf/(3*C_floor),          K_fr/C_floor]
[                      K_wf/C_WH, -(K_wf + 3*cp_w*mw_dot)/C_WH,                            0,                            0,                     0]
[                      K_wf/C_WH,         (3*cp_w*mw_dot)/C_WH, -(K_wf + 3*cp_w*mw_dot)/C_WH,                            0,                     0]
[                      K_wf/C_WH,                            0,         (3*cp_w*mw_dot)/C_WH, -(K_wf + 3*cp_w*mw_dot)/C_WH,                     0]
[                    K_fr/C_room,                            0,                            0,                            0, -(K_fr + K_ra)/C_room]...
];

B = [...
[           0,                    0,        0,        0]
[           0, (3*cp_w*mw_dot)/C_WH,        0,        0]
[           0,                    0,        0,        0]
[           0,                    0,        0,        0]
[ K_ra/C_room,                    0, 1/C_room, 1/C_room]...
];


% A = [...
% [ -(K_wf + cp_w*mw_dot)/C_return,          K_wf/C_return,                     0];
% [                   K_wf/C_floor, -(K_fr + K_wf)/C_floor,          K_fr/C_floor];
% [                              0,            K_fr/C_room, -(K_fr + K_ra)/C_room] ...
% ];
% 
% B = [...
% [           0, (cp_w*mw_dot)/C_return,        0,        0];
% [           0,                      0,        0,        0];
% [ K_ra/C_room,                      0, 1/C_room, 1/C_room] ...
% ];

A = A.*sample_time;
B = B.*sample_time;


