%% Models equations

%% 1. Building model
% The building is modeled as a 3-node thermal model.

%%% 1.1 Variables and parameters

syms C_room C_floor C_WH
syms cp_w mw_dot
syms T_room T_room_dot T_floor T_floor_dot T_ext T_return T_return_dot T_wh1 T_wh1_dot T_wh2 T_wh2_dot T_supply 
syms K_fr K_ra K_wf 
syms P_gains P_sol L
syms zero


%%% 1.2 Equation

%%%
% * *"Room node" equation*
%%%
% $$C_\mathrm{room} \dot{T}_\mathrm{room} = K_{fr} (T_\mathrm{floor} - T_\mathrm{room}) - K_{ra} (T_\mathrm{room} - T_\mathrm{ext}) + P_\mathrm{gains} + P_\mathrm{sol}$$
eq_room = C_room * T_room_dot == K_fr * (T_floor - T_room) - K_ra * (T_room - T_ext) + P_gains + P_sol + zero * (T_return + T_supply + T_wh1 + T_wh2);

%%%
% * *"Floor node" equation*
%%%
% $$C_\mathrm{floor} \dot{T}_\mathrm{floor} = - K_{fr} (T_\mathrm{floor} - T_\mathrm{room}) + K_{wf} (T_\mathrm{return} - T_\mathrm{floor}) $$
%eq_floor = C_floor * T_floor_dot == - K_fr * (T_floor - T_room) + K_wf * (T_supply - T_floor) + zero * (P_gains + P_sol + T_ext + T_return);
eq_floor = C_floor * T_floor_dot == - K_fr * (T_floor - T_room) + K_wf/3 * (T_return - T_floor) +  K_wf/3 * (T_wh1 - T_floor) + K_wf/3 * (T_wh2 - T_floor)+ zero * (P_gains + P_sol + T_ext + T_supply);

eq_wh1 = C_WH/3 * T_wh1_dot == - K_wf/3 * (T_wh1 - T_floor) + cp_w * mw_dot * (T_supply - T_wh1) + zero * (P_gains + P_sol + T_ext + T_room + T_return + T_wh2);

eq_wh2 = C_WH/3 * T_wh2_dot == - K_wf/3 * (T_wh2 - T_floor) + cp_w * mw_dot * (T_wh1 - T_wh2) + zero * (P_gains + P_sol + T_ext + T_room + T_return + T_supply);

%%%
% * *"Return node" equation*
%%%
% $$C_\mathrm{return} \dot{T}_\mathrm{return} = - K_{wf} (T_\mathrm{return} - T_\mathrm{floor}) + cp_{w} \dot{m}_\mathrm{w} (T_\mathrm{supply} - T_\mathrm{return}) $$

% L: floor heating flow fraction open [0..1]
% mw_dot: current mass flow (= L * design_mass_flow)
%eq_return = C_return * T_return_dot == - K_wf * (T_supply - T_floor) + cp_w * mw_dot * (T_supply - T_return) + zero * (P_gains + P_sol + T_ext + T_room);
eq_return = C_WH/3 * T_return_dot == - K_wf/3 * (T_return - T_floor) + cp_w * mw_dot * (T_wh2 - T_return) + zero * (P_gains + P_sol + T_ext + T_room + T_supply + T_wh1);

%%% 1.3 State-space matrices

% states = [T_return T_mid1 T_mid2 T_floor T_room ];
% states_derivatives = [T_return_dot T_mid1_dot T_mid2_dot T_floor_dot T_room_dot];

states = [T_floor T_wh1 T_wh2 T_return T_room ];
states_derivatives = [T_floor_dot T_wh1_dot T_wh2_dot T_return_dot T_room_dot];
inputs = [T_ext T_supply P_gains P_sol];

equations = solve([eq_room; eq_floor; eq_wh1; eq_wh2; eq_return], states_derivatives);
coefficients = structfun(@(eq) coeffs(eq, [states inputs]), equations, 'UniformOutput', false);
coefsAsCell = struct2cell(coefficients);
coefsMatrix = fliplr(cat(1, coefsAsCell{:,:}));
% Create State/Input matrix and substitute zero by 0
A = subs(coefsMatrix(:, 1:length(states_derivatives)), zero, 0); % State matrix
B = subs(coefsMatrix(:, length(states_derivatives)+1 : end),zero,0); % Input matrix

save('Mat_A','A');

pretty(A)
pretty(B)
A
B

%% 2. Storage model
% The storage is modeled as a 3-node thermal model.

nb_nodes = 3;
%syms nb_nodes
%%% 2.1 Variables and parameters
C_sto = sym(zeros(nb_nodes,1));
T_sto = sym(zeros(nb_nodes,1));
T_sto_dot = sym(zeros(nb_nodes,1));
K_stamb = sym(zeros(nb_nodes,1));
K_w = sym(zeros(nb_nodes-1,1));
delta_z = sym(zeros(nb_nodes-1,1));

for k=1:nb_nodes
    C_sto(k,1) = sym(sprintf('C_sto%d', k));
    T_sto(k,1) = sym(sprintf('T_sto%d', k));
    T_sto_dot(k,1) = sym(sprintf('T_sto_dot%d', k));
    K_stamb(k,1) = sym(sprintf('K_stamb%d', k));
    
    if k<=nb_nodes-1
        delta_z(k,1) = sym(sprintf('delta_z%d%d', k, k+1));
    end
    a=1;
end

%syms C_sto1 C_sto2 C_sto3
syms cp_w mw_dot mhp_dot 
%syms T_sto1 T_sto1_dot T_sto2 T_sto2_dot T_sto3 T_sto3_dot 
syms T_hp_h T_amb T_return
%syms K_sto1 K_sto2 K_sto3 K_l_12 K_l_23
syms K_w Acs
syms F alpha
syms zero
%%%
%%

bb = sym('T_sto1');
for k=1:nb_nodes-1
    bb= plus(bb,sym(sprintf('T_sto%d', k+1)));
end

eq_nod_top = C_sto(1,1).* T_sto_dot(1,1) == F*cp_w*mhp_dot.*(T_hp_h -T_sto(1,1))+ (1-alpha) .*(F*cp_w*mhp_dot-cp_w*mw_dot) .*(T_sto(1,1) - T_sto(2,1)) - K_stamb(1,1) .* (T_sto(1,1) - T_amb) + K_w .* Acs.*((T_sto(2,1) - T_sto(1,1))./(0.5.*delta_z(1,1))) + zero .*(bb + T_return);
eq_testmid = C_sto(2:end-1,1) .* T_sto_dot(2:end-1,1) == -K_stamb(2:end-1,1) .* (T_sto(2:end-1,1) - T_amb) + alpha .*(F*cp_w*mhp_dot-cp_w*mw_dot) .*(T_sto(1:end-2,1) - T_sto(2:end-1,1))+ (1-alpha) .*(F*cp_w*mhp_dot-cp_w*mw_dot).* (T_sto(2:end-1,1) - T_sto(2+1:end,1)) +  K_w .* Acs.*((T_sto(1:end-2,1) - T_sto(2:end-1,1))./(0.5.*delta_z(1:end-1,1)) + (T_sto(3:end,1) - T_sto(2:end-1,1))./(0.5.*delta_z(2:end,1))) + zero .*(bb + T_return + T_hp_h);
eq_nod_bot = C_sto(end,1).* T_sto_dot(end,1) == cp_w*mw_dot.*(T_return-T_sto(end,1)) + alpha .*(F*cp_w*mhp_dot-cp_w*mw_dot) .*(T_sto(end-1,1) - T_sto(end,1)) - K_stamb(end,1) .* (T_sto(end,1) - T_amb) + K_w .* Acs.*((T_sto(end-1,1) - T_sto(end,1))./(0.5.*delta_z(end,1))) + zero .*(bb + T_hp_h);
%%%

%%% 1.3 State-space matrices

%states = [T_return T_mid1 T_mid2 T_floor T_room ];
states_sto = T_sto(:,1).';
%states_derivatives = [T_return_dot T_mid1_dot T_mid2_dot T_floor_dot T_room_dot];
states_derivatives_sto =  T_sto_dot(:).';
inputs_sto = [T_amb T_return T_hp_h];

equations = solve([eq_nod_top; eq_testmid;eq_nod_bot ], states_derivatives_sto);
coefficients = structfun(@(x) coeffs(x, [states_sto inputs_sto]), equations, 'UniformOutput', false);
coefsAsCell = struct2cell(coefficients);
coefsMatrix = fliplr(cat(1, coefsAsCell{:,:}));
% Create State/Input matrix and substitute zero by 0
A_sto = subs(coefsMatrix(:, 1:length(states_derivatives_sto)), zero, 0); % State matrix
B_sto = subs(coefsMatrix(:, length(states_derivatives_sto)+1 : end),zero,0); % Input matrix

save('Mat_A','A');

pretty(A_sto)
pretty(B_sto)
A_sto
B_sto



