%% Resistive torque
% apply a resistive torque to the hip and knee joints based on a resistive
% force at the ankle that is proportional to the distance between the
% current gait position and the gait cycle
%
% inputs - 
% q = 3x1 joint angle input
% X = 1x2 current position
% v = 1x2 current velocity (only direction matters)
% state = 0: not in a state yet, 1: leg moving forward, 2: leg moving
% backward
% global - 
% X1 - nx2 state 1 gait cycle data
% X2 - mx2 state 2 gait cycle data
% K - global constant that scales resistive torque (empirically determined)
% d - distance from baseline before resistance starts
% outputs - 
% Q = 1x2 torque applied to hip and knee

function [Q, xcl] = resistance(q, X, v, state)

global X1 X2 K d

v = v/norm(v);
if state == 2
    x = norm(X-X1(1,:));
    xcl = X1(1,:);
    for i = 2:size(X1,1)
        x0 = norm(X-X1(i,:));
        if x0<x
            x = x0;
            xcl = X1(i,:);
        end
    end
elseif state == 1
    x = norm(X-X2(1,:));
    xcl = X2(1,:);
    for i = 2:size(X2,1)
        x0 = norm(X-X2(i,:));
        if x0<x
            x = x0;
            xcl = X2(i,:);
        end
    end
else
    x = 0;
    xcl = X;
end

if x > d
    F = K*(x-d)*v;
    Q = torque(q, F')';
else
    Q = [0, 0];
end