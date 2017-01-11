clear all
close all

StartTime = 1;
nb=2;
ChangeTime = 60*15; %secondes
sample_time = [1 60 300 900]; % secondes
%sample_time = [300]; % secondes
Stop_Time = nb*3600./sample_time(:);

for j=1:length(sample_time)
    StopTime =Stop_Time(j);
    time = [StartTime:1:StopTime]';

    %external temperature
    Text_data = load('Sion_Temperatures_January_May_m'); % minute data
    if sample_time(j) ~= 1;
        Text_data = Text_data(StartTime:(sample_time(j)/60):length(Text_data));
    else
        Text_data = Text_data(StartTime:1:length(Text_data));
        Text_data= kron(Text_data,ones(60,1));
    end
    Text = Text_data(time);
    %Text = 30 * ones(length(time),1);

    % solar radiation
    rad_90_data = load('Sion_Meteonorm_Radiation_SOUTH_90_January_May_m');
    if sample_time(j) ~= 1;
        rad_90 = rad_90_data(1:sample_time(j)/60:length(rad_90_data));
    else
        rad_90 = rad_90_data(StartTime:1:length(rad_90_data));
        rad_90 = kron(rad_90,ones(60,1));
    end
    rad_90 = rad_90(time);

    % gains
    Psol = 4 * rad_90;
    Gin = zeros(length(time),1);

    % Heat supply
    Ts_max =  40;
    Tws = repmat([30*ones(ChangeTime/sample_time(j),1); Ts_max*ones(length(time)/nb-nb*ChangeTime/sample_time(j),1); Ts_max-20*ones(nb*ChangeTime/sample_time(j),1)],nb,1);
    flow_fraction = 0.5;

    % Init temperature 
    Tb_ini =[25 27 26 23 20]';
    %Tb_ini =[30 30 30]';
    Tb_in = Tb_ini;
    Tb_vec = zeros(length(Tb_ini),length(time));
    Tb_vec(:,1) = Tb_ini;
    Tb_save = zeros(length(Tb_ini),length(time)/(3600/(4*sample_time(j))));
    Tb_save(:,1) = Tb_ini;

    k=1;
    for i = 1:length(time)-1
        [Tb_out, Q_d] = Simulate_building_dynamics(Tb_in , Text(i), Gin(i), Psol(i), Tws(i), flow_fraction,sample_time(j));
        %Tb = [Treturn, Tfloor, Troom]'
        Tws;
        Tb_in = Tb_out;
        Tb_vec(:,i+1) = Tb_out;

        % save every 15 min data
        if i == k*(60)/sample_time(j)
            Tb_save(:,k+1) = Tb_vec(:,i+1);
            k=k+1;
        end
    end
   Tb_vec_str{j} =  Tb_vec;
   Tb_save_str{j} = Tb_save;
   
   clear Tb_vec Tb_save Tb_in
end

n = 5;
if n > min(StopTime);
    n = min(StopTime);
end

figure(1)
subplot(2,2,1)
stairs(Tb_vec_str{1}(:,ChangeTime/sample_time(1):ChangeTime/sample_time(1)+n-1)','-*');
hold on
stairs(Tws(1:n),'-*g');
title('Dt_{step} = 1s')
xlabel('time [s]')
ylabel('T [°C]')
ylim([0,Ts_max+10])
hold off

t_step = repmat(linspace(0,n-1,n),length(Tb_out),1)';

Tb_vec_str{1}(:,ChangeTime/sample_time(1):ChangeTime/sample_time(1)+n-1)
Tb_vec_str{2}(:,ChangeTime/sample_time(2):ChangeTime/sample_time(2)+n-1)
Tb_vec_str{3}(:,ChangeTime/sample_time(3):ChangeTime/sample_time(3)+n-1)
Tb_vec_str{4}(:,ChangeTime/sample_time(4):ChangeTime/sample_time(4)+n-1)


subplot(2,2,2)
stairs(t_step, Tb_vec_str{2}(:,ChangeTime/sample_time(2):ChangeTime/sample_time(2)+n-1)','-*');
hold on
stairs(t_step(:,1),Tws(1:n),'-*g');
title('Dt_{step} = 1 min')
xlabel('time [min]')
ylabel('T [°C]')
ylim([0,Ts_max+10])
hold off

subplot(2,2,3)
stairs(t_step*5,Tb_vec_str{3}(:,ChangeTime/sample_time(3):ChangeTime/sample_time(3)+n-1)','-*');
hold on
stairs(t_step(:,1)*5,Tws(1:n),'-*g');
title('Dt_{step} = 5 min')
xlabel('time [min]')
ylabel('T [°C]')
ylim([0,Ts_max+10])
hold off

subplot(2,2,4)
stairs(t_step*15,Tb_vec_str{4}(:,ChangeTime/sample_time(4):ChangeTime/sample_time(4)+n-1)','-*');
hold on
stairs(t_step(:,1)*15,Tws(1:n),'-*g');
title('Dt_{step} = 15 min')
xlabel('time [min]')
ylabel('T [°C]')
ylim([0,Ts_max+10])
hold off

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Response of the first steps following a T_{supply} increase','HorizontalAlignment','center','VerticalAlignment', 'top')

t_step = repmat(linspace(0,8-1,8),length(Tb_save_str{1}),1)';


%%
figure(2)
subplot(3,1,1)
stairs(linspace(0,length(Tb_vec_str{1}(1,:))-1,length(Tb_vec_str{1}(1,:))),Tb_vec_str{1}(1,:),'-b')
hold on
stairs(60*linspace(0,length(Tb_vec_str{2}(1,:))-1,length(Tb_vec_str{2}(1,:))),Tb_vec_str{2}(1,:)','-g')
stairs(300*linspace(0,length(Tb_vec_str{3}(1,:))-1,length(Tb_vec_str{3}(1,:))),Tb_vec_str{3}(1,:)','-*y')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tb_vec_str{4}(1,:)','-*c')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tws(1:length(Tb_vec_str{4}(1,:)')),'r');
ylim([20, 40])
xlabel('time [s]')
ylabel('T [°C]')
legend('T_{return}','T_{floor}','T_{room}', 'T_{supply}')
legend('\Delta_t = 1 s','\Delta_t = 1 min','\Delta_t = 5 min', '\Delta_t = 15 min')
title('T_{return} change')
hold off

subplot(3,1,2)
stairs(linspace(0,length(Tb_vec_str{1}(1,:))-1,length(Tb_vec_str{1}(1,:))),Tb_vec_str{1}(2,:),'-b')
hold on
stairs(60*linspace(0,length(Tb_vec_str{2}(1,:))-1,length(Tb_vec_str{2}(1,:))),Tb_vec_str{2}(2,:)','-g')
stairs(300*linspace(0,length(Tb_vec_str{3}(1,:))-1,length(Tb_vec_str{3}(1,:))),Tb_vec_str{3}(2,:)','-*y')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tb_vec_str{4}(2,:)','-*c')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tws(1:length(Tb_vec_str{4}(1,:)')),'r');
ylim([15, Ts_max+10])
xlabel('time [s]')
ylabel('T [°C]')
legend('\Delta_t = 1 s','\Delta_t = 1 min','\Delta_t = 5 min', '\Delta_t = 15 min')
title('T_{floor} change')
hold off

subplot(3,1,3)
stairs(linspace(0,length(Tb_vec_str{1}(1,:))-1,length(Tb_vec_str{1}(1,:))),Tb_vec_str{1}(3,:),'-b')
hold on
stairs(60*linspace(0,length(Tb_vec_str{2}(1,:))-1,length(Tb_vec_str{2}(1,:))),Tb_vec_str{2}(3,:)','-g')
stairs(300*linspace(0,length(Tb_vec_str{3}(1,:))-1,length(Tb_vec_str{3}(1,:))),Tb_vec_str{3}(3,:)','-*y')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tb_vec_str{4}(3,:)','-*c')
stairs(900*linspace(0,length(Tb_vec_str{4}(1,:))-1,length(Tb_vec_str{4}(1,:))),Tws(1:length(Tb_vec_str{4}(1,:)')),'r');
ylim([15, Ts_max+10])
xlabel('time [s]')
ylabel('T [°C]')
legend('\Delta_t = 1 s','\Delta_t = 1 min','\Delta_t = 5 min', '\Delta_t = 15 min')
title('T_{room} change')
hold off

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Comparison of steps response following a T_{supply} increase','HorizontalAlignment','center','VerticalAlignment', 'top')


% %%
% figure(3)
% subplot(3,1,1)
% stairs(t_step(:,1)*t,Tb_save_str{1}(1,:)','-b')
% hold on
% stairs(t_step(:,1)*t,Tb_save_str{2}(1,:)','-g')
% hold on
% stairs(t_step(:,1)*t,Tb_save_str{3}(1,:)','-y')
% hold on
% stairs(t_step(:,1)*t,Tb_save_str{4}(1,:)','-c')
% %ylim([15, 40])
% hold off
% subplot(3,1,2)
% stairs(t_step(:,1)*t,Tb_save_str{1}(2,:)','--b')
% hold on
% stairs(t_step(:,1)*t,Tb_save_str{2}(2,:)','--g')
% stairs(t_step(:,1)*t,Tb_save_str{3}(2,:)','--y')
% stairs(t_step(:,1)*t,Tb_save_str{4}(2,:)','--c')
% % stairs(t_step(:,1)*15,Tws(1:8),'r');
% % ylim([15, 40])
% hold off
% subplot(3,1,3)
% stairs(t_step(:,1)*t,Tb_save_str{1}(3,:)','-*b')
% hold on
% stairs(t_step(:,1)*t,Tb_save_str{2}(3,:)','-*g')
% stairs(t_step(:,1)*t,Tb_save_str{3}(3,:)','-*y')
% stairs(t_step(:,1)*t,Tb_save_str{4}(3,:)','-*c')
% % stairs(t_step(:,1)*15,Tws(1:8),'r');
% % ylim([15, 40])
% hold off
% legend('\Delta_t = 1 s','\Delta_t = 1 min','\Delta_t = 5 min', '\Delta_t = 15 min')

