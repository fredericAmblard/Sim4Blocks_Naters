%% Compute the steady stae of a building
function [XSS,USS] = get_ini_state_building (Tin,Text,building)
% Tin : room temperature
% Text : external temperature
% building : structure of buildings parameters

% Steady state condition: dT/dt = 0
% A x Xss + B x Uss = 0

[A, B] = get_state_input_mat_building(building, 'h');

A_mat = zeros(3,3);
B_mat = zeros(3,1);

A_mat(:,1:2) = A(:,1:2);
A_mat(:,3) = B(:,2);
B_mat(:) = - A(:,3) * Tin - B(:,2) * Text;

SS = A_mat\B_mat;
XSS = [SS(1:2,1); Tin];
USS = [Text; SS(3,1)];



