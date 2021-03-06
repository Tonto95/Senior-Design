close all;
clearvars;

%% load gait data

% time, hip, knee, ankle, and toe position data respectively (cm to m)
T = xlsread('Winter_Appendix_data.xlsx','A1.Raw_Coordinate', 'B4:B109');
xh = xlsread('Winter_Appendix_data.xlsx','A1.Raw_Coordinate', 'E4:F109')/100;
xk = xlsread('Winter_Appendix_data.xlsx','A1.Raw_Coordinate', 'G4:H109')/100;
xa = xlsread('Winter_Appendix_data.xlsx','A1.Raw_Coordinate', 'K4:L109')/100;
xt = xlsread('Winter_Appendix_data.xlsx','A1.Raw_Coordinate', 'Q4:R109')/100;

% velocities
vxh = xlsread('Winter_Appendix_data.xlsx','A2.Filtered_Marker_Kinematics', 'L5:L110');
vyh = xlsread('Winter_Appendix_data.xlsx','A2.Filtered_Marker_Kinematics', 'O5:O110');
vxa = xlsread('Winter_Appendix_data.xlsx','A2.Filtered_Marker_Kinematics', 'AG5:AG110');
vya = xlsread('Winter_Appendix_data.xlsx','A2.Filtered_Marker_Kinematics', 'AJ5:AJ110');

% joint angles (theta, omega, alpha: ankle, knee, hip)
dataq = xlsread('Winter_Appendix_data.xlsx','A4.RelJointAngularKinematics', 'D5:L110');
q = dataq(:,[7 4 1])*pi/180; % degrees to radians (hip, knee, ankle)
qdot = dataq(:,[8 5 2]);
qdotdot = dataq(:,[9 6 3]);

% moments
Ma = xlsread('Winter_Appendix_data.xlsx','A5.ReactionForces&Moments', 'I6:I111');
Mk = xlsread('Winter_Appendix_data.xlsx','A5.ReactionForces&Moments', 'P6:P111');
Mh = xlsread('Winter_Appendix_data.xlsx','A5.ReactionForces&Moments', 'X6:X111');

%% calculations
global L

L_calc = @(i) [norm(xh(i,:)-xk(i,:));
    norm(xk(i,:)-xa(i,:));
    norm(xa(i,:)-xt(i,:))];
L = L_calc(1);

L_full = zeros(3,size(xh,1));
for i = 1:size(xh,1)
    L_full(:,i) = L_calc(i);
end

L = mean(L_full,2);

x = xa-xh;
xfk = zeros(size(q,1),2);
for i = 1:size(xfk,1)
%     L = L_calc(i);
    X = fk(q(i,:)');
    xfk(i,:) = X(:,2)';
end
xfkpc = zeros(size(q,1),2);
for i = 1:size(xfkpc,1)
%    L = L_calc(i);
    X = fkNew(q(i,:));
    xfkpc(i,:) = X(4,:);
end
% Note ankle angle is not strictly accurate for ik.m, it is just the ankle
% angle that makes the foot parallel to the ground
qik = zeros(size(x,1),3);
for i = 1:size(qik,1)
%    L = L_calc(i);
    Q = ik(x(i,:)');
    qik(i,:) = Q';
end

%% plot
figure(1);
hold on;
axis equal;
scatter(x(:,1), x(:,2), '.b');
scatter(xfk(:,1), xfk(:,2), '.r');
scatter(xfkpc(:,1), xfkpc(:,2), '.y');
legend('measured', 'calculated','polycentric joint');
xlabel('Ankle X Position (m)');
ylabel('Ankle Y Position (m)');

figure(2);
hold on;
scatter(T, x(:,1), '.b');
scatter(T, xfk(:,1), '.r');
scatter(T, xfkpc(:,1), '.y');
legend('measured', 'calculated','polycentric joint');
xlabel('Time (s)');
ylabel('Ankle X Position (m)');

figure(3);
hold on;
scatter(T, x(:,2), '.b');
scatter(T, xfk(:,2), '.r');
scatter(T, xfkpc(:,2), '.y');
legend('measured', 'calculated','polycentric joint');
xlabel('Time (s)');
ylabel('Ankle Y Position (m)');

figure(4);
hold on;
scatter(T, q(:,1), '.');
scatter(T, qik(:,1), '.');
legend('measured', 'calculated');
xlabel('Time (s)');
ylabel('Hip Angle (rad)');

figure(5);
hold on;
scatter(T, q(:,2), '.');
scatter(T, qik(:,2), '.');
legend('measured', 'calculated');
xlabel('Time (s)');
ylabel('Knee Angle (rad)');

figure(6);
hold on;
yyaxis left;
scatter(T, qdot(:,1), '.b');
scatter(T, qdot(:,2), '.g');
ylabel('Angular Velocity (rad/s)');
yyaxis right;
scatter(T, q(:,1), '.r');
scatter(T, q(:,2), '.k');
ylabel('Joint Angle (rad)');
xlim([0,1]);
legend('hip angular velocity', 'knee angular velocity', 'hip angle', 'knee angle');
xlabel('Time (s)');


% figure(7);
% hold on;
% axis equal;
% H1 = plot(x(1,1), x(1,2), '-k');
% H2 = scatter(x, y, 0.05, 'b');
% set(H1, 'XData', [0, X(1,1:3)]);
% set(H1, 'YData', [0, X(2,1:3)]);
% set(H2, 'XData', [0, X(1,1:3)]);
% set(H2, 'YData', [0, X(2,1:3)]);