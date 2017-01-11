%% Models equations

%% 1. Building model
% The building is modeled as a 3-node thermal model.

%%% 1.1 Variables and parameters

syms C_room C_floor
syms cp_w mw_dot
syms T_room T_room_dot T_floor T_floor_dot T_ext T_supply  T_return
syms K_fr K_ra K_wf
syms P_gains P_sol L
syms zero

%%% 1.2 Equation

%%%
% * *"Room node" equation*
%%%
% $$C_\mathrm{room} \dot{T}_\mathrm{room} = K_{fr} (T_\mathrm{floor} - T_\mathrm{room}) - K_{ra} (T_\mathrm{room} - T_\mathrm{ext}) + P_\mathrm{gains} + P_\mathrm{sol}$$
eq_room = C_room * T_room_dot == K_fr * (T_floor - T_room) - K_ra * (T_room - T_ext) + P_gains + P_sol + zero * (T_supply + T_return);

%%%
% * *"Floor node" equation*
%%%
% $$C_\mathrm{floor} \dot{T}_\mathrm{floor} = - K_{fr} (T_\mathrm{floor} - T_\mathrm{room}) + K_{wf} (T_\mathrm{return} - T_\mathrm{floor}) $$
%eq_floor = C_floor * T_floor_dot == - K_fr * (T_floor - T_room) + K_wf * (T_supply - T_floor) + zero * (P_gains + P_sol + T_ext + T_return);
eq_floor = C_floor * T_floor_dot == - K_fr * (T_floor - T_room) +  cp_w * mw_dot * (T_supply - T_return) + zero * (P_gains + P_sol + T_ext);

%%%
% * *"Return node" equation*
%%%
% $$C_\mathrm{return} \dot{T}_\mathrm{return} = - K_{wf} (T_\mathrm{return} - T_\mathrm{floor}) + cp_{w} \dot{m}_\mathrm{w} (T_\mathrm{supply} - T_\mathrm{return}) $$

% L: floor heating flow fraction open [0..1]
% mw_dot: current mass flow (= L * design_mass_flow)
%eq_return = C_return * T_return_dot == - K_wf * (T_supply - T_floor) + cp_w * mw_dot * (T_supply - T_return) + zero * (P_gains + P_sol + T_ext + T_room);
%eq_return = T_return == cp_w * mw_dot * (T_supply - T_floor) + zero * (P_gains + P_sol + T_ext + T_room);

%%% 1.3 State-space matrices

states = [T_floor T_room];
states_derivatives = [T_floor_dot T_room_dot];
inputs = [T_ext T_supply T_return P_gains P_sol];

equations = solve([eq_room; eq_floor], states_derivatives);
coefficients = structfun(@(eq) coeffs(eq, [states inputs]), equations, 'UniformOutput', false);
coefsAsCell = struct2cell(coefficients);
coefsMatrix = fliplr(cat(1, coefsAsCell{:,:}));
% Create State/Input matrix and substitute zero by 0
A = subs(coefsMatrix(:, 1:length(states_derivatives)), zero, 0); % State matrix
B = subs(coefsMatrix(:, length(states_derivatives)+1 : end),zero,0); % Input matrix

pretty(A)
pretty(B)
A
B

%% 2. Storage model
% The storage is modeled as a 3-node thermal model.

%%% 2.1 Variables and parameters
syms C_sto1 C_sto2 C_sto3
syms cp_w mw_dot mhp_dot 
syms T_sto1 T_sto1_dot T_sto2 T_sto2_dot T_sto3 T_sto3_dot T_hp_h T_hp_h_dot T_amb T_return T_return_dot 
syms K_sto1 K_sto2 K_sto3 K_l_12 K_l_23 
syms F alpha
syms zero
%%%
%%

%%%
% $$ \alpha = \left\{\begin{matrix} 
% \beta \cr
% \eta \end{matrix}\right.  $$