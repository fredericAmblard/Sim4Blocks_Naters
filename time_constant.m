Ci=[2.07 1.36 1.07];
Ce = 2.92;
Ch = [0.309 0.00139];
Ria = [5.29 5.31];
Rih= [0.639 93.4];
Rie = 0.863;
Rea = 4.54;
tau_1 = Ria(1)*Ci;
tau_2_1 = (Ci(2)*Ria(2)*Rih(1))/(Ria(2)+Rih(1))
tau_2_1 = 1/((1/Ci(2))*(1/(Ria(2) + Rih(1))))
tau_2_2 = Ch(1) * Rih(1)
tau_3_1 = 1/((1/Ci(3))*(1/Rih(2)+1/Rie))
% tau_3_2
% tau_3_2
Aw = [7.89 6.22];

a=(5.31+0.639)*(1.36+0.309)

A = [-1/(Ria(1)*Ci(1))];
B = [1/(Ria(1)*Ci(1)) Aw(1)/Ci(1) 1/Ci(1)];

A2 = [-(1/(Ria(2)*Ci(2))+1/(Rih(1)*Ci(2))), 1/(Rih(1)*Ci(2)); 1/(Rih(1)*Ch(1)), -1/(Rih(1)*Ch(1))];
B2 = [1/(Ria(2)*Ci(2)) Aw(2)/Ci(2) 0; 0 0 1/Ch(1)];

sys1 = ss(A/3600,B,eye(size(A,1)), zeros(size(A,1), size(B,2)))
sys2 = ss(A2/3600,B2,eye(size(A2,1)), zeros(size(A2,1), size(B2,2)))
figure(1)
impulse(sys1);
figure(2)
impulse(sys2);
[y, T] = impulse(sys1);
[y2, T2] = impulse(sys2);

tau1 = T(find(y(:,1,2)<=0.3678*y(1,1,2),1))/3600
tau21 = T2(find(y2(:,1,1)<=0.3678*y2(1,1,1),1))/3600
tau22 = T2(find(y2(:,2,3)<=0.3678*y2(1,2,3),1))/3600