function [Ates_d, Btes_d, F, L] = get_state_input_mat_storage(building, HP_st, FH_st, time_unit)

% Create the state matrix and the input matrix for the thermal storage system

% state vector for the thermal storage
% x_b = [Tws, Tbb, Thp_s, Twr]'

% input vector for the building
% u_b = [Text, Qhp, Qdem]

[C_tes_top, C_tes_bot, K_sta_1, K_sta_2, K_l, C_w_hp, C_w_fh, mc_w, K_wa_fh, K_wa_hp] = get_param_storage(building);

% Matrix predefinition

A = zeros(4,4); 
B = zeros(4,3); 

F = HP_st; %'ToDo';
L = FH_st; %'ToDo';

mc_hp = mc_w;

%% State Matrix
% Equation for temperature of water supply Tws
A(1,1) = - (F * mc_hp + L * mc_w + K_sta_1 + K_l) / C_tes_top;
A(1,2) = (L * mc_w + K_l) / C_tes_top;
A(1,3) = F * mc_hp / C_tes_top;

% Equation for bottom layers' temperature of TES 
A(2,1) = (L * mc_w + K_l) / C_tes_bot;
A(2,2) = - (F * mc_hp + L * mc_w + K_sta_2 + K_l) / C_tes_bot;
A(2,4) = L * mc_w / C_tes_bot;

% Equation for supply temperature of the Heat Pump
A(3,2) = F * mc_hp / C_w_hp;
A(3,3) = - (F * mc_hp + K_wa_hp) / C_w_hp;

% Equation for temperature of the return water
A(4,1) = L * mc_hp / C_w_fh;
A(4,4) = - (L * mc_hp + K_wa_fh) / C_w_fh;


%% Input matrix
B(1,1) = K_sta_1 /  C_tes_top;
B(2,1) = K_sta_2 /  C_tes_bot;
B(3,1) = K_wa_hp /   C_w_hp;
B(4,1) = K_wa_fh /  C_w_fh;
B(3,2) = 1 / C_w_hp;
B(4,3) = -1 / C_w_fh;


if strcmp(time_unit, 'h')
    A = A.*3600;
    B = B.*3600;
elseif strcmp(time_unit, '1/4h')
    A = A.*900;
    B = B.*900;
end

Ates_d = exp(time_unit*A);
Btes_d = A\(exp(time_unit*A)-eye(4))*B;
% nxsto =4;
% sysstoc = ss(A ,B ,eye(nxsto), zeros(nxsto, size(B, 3)));
% % discrete building model
% sysstod = c2d(sysstoc, 1);
% [Ates_d, Btes_d] = ssdata(sysstod);
