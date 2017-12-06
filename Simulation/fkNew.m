% q = 3x1 joint angle input (hip, knee, angle)
% L = 3xl link lengths (hip-knee, knee-ankle, ankle-foot)
%output x 4x2 hip, knee, angle and foot positions 
function pos=fkNew(q)
global L
pos=zeros(4,2);
A1=[cos(q(1)+pi/2) -sin(q(1)+pi/2) 0 -L(1)*cos(q(1)+pi/2);
    sin(q(1)+pi/2) cos(q(1)+pi/2) 0 -L(1)*sin(q(1)+pi/2);
    0 0 1 0;
    0 0 0 1;];
A2=[cos(q(2)) -sin(q(2)) 0 -L(2)*cos(q(2));
    sin(q(2)) cos(q(2)) 0 -L(2)*sin(q(2));
    0 0 1 0;
    0 0 0 1;];
A3=[cos(q(3)-pi/2) -sin(q(3)-pi/2) 0 L(3)*cos(q(3)-pi/2);
    sin(q(3)-pi/2) cos(q(3)-pi/2) 0 L(3)*sin(q(3)-pi/2);
    0 0 1 0;
    0 0 0 1;];
knee=(A1*[0;0;0;1])';
angle=(A1*A2*[0;0;0;1])';
foot=(A1*A2*A3*[0;0;0;1])';
pos(2,:)=knee(1:2);
pos(3,:)=angle(1:2);
pos(4,:)=foot(1:2);
grid on

plot(pos(:,1),pos(:,2),'o-');
axis([-1 1 -0.8 0]);
axis equal 