function [A, B, Qdot, facHP, nb, K, Design] = get_state_input_mat_building(building, time_unit)

% Create the state matrix and the input matrix for the building system

% state vector for the building
% x_b = [Twr, Tf, Tin]'

% input vector for the building
% u_b = [Text, Tws, Qaux]

[C_wr, mc_f, C_r, mc_w, K_wf, K_fr, K_ra, Qdot, facHP, nb, K, Design] = get_param_building(building);

% Matrix predefinition
% A = zeros(5,5); % NEED CHECK
% B = zeros(5,3); % NEED CHECK
A = zeros(3,3); 
B = zeros(3,2); 

%% State Matrix
% Equation for temperature of water return Twr
A(1,1) = - (mc_w + K_wf) / C_wr;
A(1,2) = K_wf / C_wr;

% Equation for temperature of the floor Tf
A(2,1) = K_wf / mc_f;
A(2,2) = - (K_fr + K_wf) / mc_f;
A(2,3) = K_fr / mc_f;

% Equation for temperature of the room Tin
A(3,2) = K_fr / C_r;
A(3,3) = - (K_fr + K_ra) / C_r;

%% Input matrix
B(1,2) = mc_w / C_wr;
B(3,1) = K_ra / C_r;
%B(4,1) = - h_out / (c_wall * rho_wall * L / 2);

if strcmp(time_unit, 'h')
    A = A.*3600;
    B = B.*3600;
elseif strcmp(time_unit, '1/4h')
    A = A.*900;
    B = B.*900;
end

