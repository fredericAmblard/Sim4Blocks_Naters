%% Compute the steady stae of a building
function [XSS,USS] = get_ini_state_building (Tin,Text,building)
% Tin : room temperature
% Text : external temperature
% building : structure of buildings parameters

% Steady state condition: dT/dt = 0
% A x Xss + B x Uss = 0

[A, B] = get_state_input_mat_building(building, 'h');

A_mat = zeros(5,5);
B_mat = zeros(5,1);

A_mat(:,1:4) = A(:,1:4);
A_mat(:,3) = B(:,1);
B_mat(:) = - A(:,5) * Tin - B(:,1) * Text;

SS = A_mat\B_mat;
XSS = [SS(1:2,1); Tin];
USS = [Text; SS(3,1)];



