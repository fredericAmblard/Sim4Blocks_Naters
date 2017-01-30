function [ K ] = get_param_hp(Q_D)
%GET_PARAM_HP returns the parameters of the selected building
%   This function selects the Heating, Source and Electric power matrix of
%   a HP based on the design heat demand estimated Q_D and return the
%   estimated linear parameters of the heat pump

% Heat pump system sizing
beta_HP =0.8;
% inlet source temperature vector
Thp_source = [2 10 15]; % [°C]
% outlet/sink temperature vector
Thp_sink = [35 45 55 60]; % [°C]

if(0 <= Q_D)  && (Q_D < 10e3)
    rror('lookuptable for this size of heat pump is missing')
elseif (10e3 <= Q_D)  && (Q_D < 25e3)  % Vitocal 300-G, Typ BW 301.A17 
    Q_cold = 1e3*[14.83 13.31 11.53 10.48; 19.05 17.3 15.21 14.02; 21.81, 19.91 17.62 16.32]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[18.23 17.57 16.85 16.4; 22.47 21.58 20.53 19.93; 25.24, 24.15, 22.9, 22.23]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[3.66, 4.58, 5.72, 6.37; 3.67, 4.6, 5.73, 6.35; 3.7, 4.56, 5.68, 6.35]; % Electric power matrix (compressor) [W]
elseif (25e3 <= Q_D)  && (Q_D < 29e3) % Vitocal 300-G, Typ BW 301.A21 
    Q_cold = 1e3*[18 15.9 14.1 13.2; 23.3 21 18.7 17.3; 26.7, 24 21.7 19.9]; % Heating power matrix (condenser) [W]
    Q_hot = 1e3*[22.7 21.5 20.3 19.8; 28 26.7 25 24.3; 31, 29.7, 27.7, 27]; % Source power matrix (evaporator) [W]
    Pel = 1e3*[4.7, 5.7, 6.8, 7.3; 4.7, 5.7, 6.8, 7.3; 4.8, 5.8, 6.8, 7.3]; % Electric power matrix (compressor) [W]
elseif (29e3 <= Q_D)  && (Q_D < 36e3)
    error('lookuptable for this size of heat pump is missing')
end

A = [subsref(Q_hot(:,:).', substruct('()', {':'})),subsref(Q_cold(:,:).', substruct('()', {':'})), subsref(Pel(:,:).', substruct('()', {':'})), repelem(Thp_source,length(Thp_sink(:)))', repmat(Thp_sink(1:end),1,length(Thp_source))'];
A_heat = A([1:2 5:6 9:10],:);
A_DHW = A([3:4 7:8 11:12],:);

% Recover linear parameters K of the heat pump
K_heat = hp_param(A_heat);  % Tsink [35 45]
K_DHW = hp_param(A_DHW);   % Tsink [55 60]
K =[K_heat; K_DHW];
% Q_daikin = 5000;%Q_range_HP(Ts_D , 5);
% facHP = beta_HP * Q_D / Q_daikin(end);
% nb = beta_HP * Q_D / 5000;
end



%old dataset
% if(0 <= Q_D)  && (Q_D < 10e3)
%     Q_cold = 1e3*[4.75 5 4.7 3.9; 9, 8.75 8.4 7.5]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[6.3 7.3 7.3 7.3; 11.1, 11.55, 11.55, 11.55]; % Source power matrix (evaporator) [W]
%     Pel = 1e3*[1.65, 2.3, 2.75, 3.4; 2.1, 2.8, 3.2, 4]; % Electric power matrix (compressor) [W]
% elseif (10e3 <= Q_D)  && (Q_D < 25e3)  % Vitocal 300-G, Typ BW 301.A17 
%     Q_cold = 1e3*[11.13 9.82 10.6 10.48; 21.81, 19.91 17.62 16.32]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[14.52 14.07 15.92 16.4; 25.24, 24.15, 22.9, 22.23]; % Source power matrix (evaporator) [W]
%     Pel = 1e3*[3.64, 4.57, 5.72, 6.37; 3.7, 4.56, 5.68, 6.35]; % Electric power matrix (compressor) [W]
% elseif (25e3 <= Q_D)  && (Q_D < 29e3) % Vitocal 300-G, Typ BW 301.A21 
%     Q_cold = 1e3*[13.8 12.3 10 9; 26.7, 24 21.7 19.9]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[18 17 15.8 15.5; 31, 29.7, 27.7, 27]; % Source power matrix (evaporator) [W]
%     Pel = 1e3*[5.75, 6.25, 7.1, 7.6; 5.95, 7.2, 7.1, 7.6]; % Electric power matrix (compressor) [W]
% elseif (29e3 <= Q_D)  && (Q_D < 36e3)
%     Q_cold = 1e3*[18.25 17.2 16 14.5; 31.3, 29.9 28.2 26.1]; % Heating power matrix (condenser) [W]
%     Q_hot = 1e3*[20.3 20.3 20.3 20.3; 38.9, 38.9, 38.9, 38.9]; % Source power matrix (evaporator) [W]
%     Pel = 1e3*[6.75, 7.75, 8.8, 10.4; 7.5, 9, 10.75, 12.8]; % Electric power matrix (compressor) [W]
% end