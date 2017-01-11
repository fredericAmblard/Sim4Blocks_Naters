function [ K ] = get_param_hp(Q_D)
%GET_PARAM_HP returns the parameters of the selected building
%   This function selects the Heating, Source and Electric power matrix of
%   a HP based on the design heat demand estimated Q_D and return the
%   estimated linear parameters of the heat pump

% Heat pump system sizing
beta_HP =0.8;
% inlet source temperature vector
Thp_source = [-5 15]; % [°C]
% outlet/sink temperature vector
Thp_sink = [35 45 55 65]; % [°C]

if(0 <= Q_D)  && (Q_D < 10e3)
    Q_cold = 1e3*[4.75 5 4.7 3.9; 9, 8.75 8.4 7.5]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[6.3 7.3 7.3 7.3; 11.1, 11.55, 11.55, 11.55]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[1.65, 2.3, 2.75, 3.4; 2.1, 2.8, 3.2, 4]; % Electric power matrix (compressor) [W]
elseif (10e3 <= Q_D)  && (Q_D < 29e3)
    Q_cold = 1e3*[14.8 14.1 13.2 11.6; 24.75, 23.3 22 20.4]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[24.9 24.9 24.9 24.9; 30.5, 30.5, 30.5, 30.5]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[5.75, 6.25, 7.1, 8.8; 5.95, 7.2, 8.75, 10.2]; % Electric power matrix (compressor) [W]
elseif (29e3 <= Q_D)  && (Q_D < 36e3)
    Q_cold = 1e3*[18.25 17.2 16 14.5; 31.3, 29.9 28.2 26.1]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[20.3 20.3 20.3 20.3; 38.9, 38.9, 38.9, 38.9]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[6.75, 7.75, 8.8, 10.4; 7.5, 9, 10.75, 12.8]; % Electric power matrix (compressor) [W]
end

A = [subsref(Q_hot.', substruct('()', {':'})),subsref(Q_cold.', substruct('()', {':'})), subsref(Pel.', substruct('()', {':'})), repelem(Thp_source,length(Thp_sink))', repmat(Thp_sink,1,2)']; 

% Recover linear parameters K of the heat pump
K = hp_param(A);
% Q_daikin = 5000;%Q_range_HP(Ts_D , 5);
% facHP = beta_HP * Q_D / Q_daikin(end);
% nb = beta_HP * Q_D / 5000;
end

