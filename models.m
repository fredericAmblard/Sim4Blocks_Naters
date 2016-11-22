%% Models equations

%% Building model
% The building is modeled as a 3-node thermal model.
syms C_room C_floor C_return
syms cpw mw_dot
syms T_room T_room_dot T_floor T_floor_dot T_ext T_return T_return_dot T_supply 
syms K_fr K_ra K_wf 
syms P_gains P_sol thermal_capacity_flow L
syms zero

%%
% $$C_\mathrm{room} \dot{T}_\mathrm{room} = K_{fr} (T_\mathrm{floor} - T_\mathrm{room}) - K_{ra} (T_\mathrm{room} - T_\mathrm{ext}) + P_\mathrm{gains} + P_\mathrm{sol}$$
eq_room = C_room * T_room_dot == K_fr * (T_floor - T_room) - K_ra * (T_room - T_ext) + P_gains + P_sol + zero * (T_return + T_supply);

%%
% $$42$$
eq_floor = C_floor * T_floor_dot == - K_fr * (T_floor - T_room) + K_wf * (T_return - T_floor) + zero * (P_gains + P_sol + T_ext + T_supply);

%% Return node

% L: floor heating flow fraction open [0..1]
% mw_dot: current mass flow (= L * design mass flow)
eq_return = C_return * T_return_dot == - K_wf * (T_return - T_floor) + cpw * mw_dot * (T_supply - T_return) + zero * (P_gains + P_sol + T_ext + T_room);

%% State-space matrices
states = [T_return T_floor T_room];
states_derivatives = [T_return_dot T_floor_dot T_room_dot];
inputs = [T_ext T_supply P_gains P_sol];

equations = solve([eq_room; eq_floor; eq_return], states_derivatives);
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
