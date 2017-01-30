function K = hp_param(A) %HP_PARAM calculates the parameters K(1), K(2), K(3),
% This file is part of the CARNOT Blockset.
% 
% Copyright (c) 1998-2015, Solar-Institute Juelich of the FH Aachen.
% Additional Copyright for this file see list auf authors.
% All rights reserved.

%input: a matrix A where each row has five elements
%       (specify at least two rows for A)
%
%       [qdot_hot qdot_cold     pel     tcold      thot]
%
%   first element is the heating power
%         qdot_hot = A(:,1);
%
%   second element is the absorbing power
%         qdot_cold = A(:,2);
%
%   third element is the electric power
%         pel = A(:,3);
%
%   fourth element is the corresponding source temperature
%         (usually the source side inlet temperature)
%         tcold = A(:,4);
%
%   fifth element is the corresponding sink temperature
%         (usually the outlet temperature of the house-heating)
%         thot = A(:,5);

% K(4), K(5), K(6), K(7), K(8) and K(9)
% for the heat-pump model in the CARNOT library.
% K(1), K(2) and K(3) are used to estimate the
% heating power ; K(4), K(5) and K(6) enable to
% calculate electric power ; K(7), K(8) and K(9) are used to
% have absorbing power.
% The model works with a linear characteristics.
% Specify heating, absorbing and electric power only at lowest and highest
% temperatures. Other values will be interpolated.


K(1:3) = fminsearch(@(x) hp_param_func(x, A, 'heat'), [100 -5 100]);
K(4:6) = fminsearch(@(x) hp_param_func(x, A, 'electric'), [100 -5 100]);
K(7:9) = fminsearch(@(x) hp_param_func(x, A, 'absorbing'), [100 -5 100]);

end
function f = hp_param_func(x, A, type)
    if (strcmp(type,'heat'))
        f = sum((A(:,1) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
    elseif (strcmp(type,'electric'))
        f = sum((A(:,3) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
    else   
        f = sum((A(:,2) -x(1).*A(:,4) - x(2).*A(:,5) - x(3)).^2);
    end
end
