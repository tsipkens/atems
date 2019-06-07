

s.pos = [2,2,1];
s.r = 0.5;


c.pos = [-1,0,0];
c.view = [1,1,0];
c.view = c.view./norm(c.view);
c.size = 1;
c.d = 0.5;
c.plane = c.view.*c.d;

vec0 = s.pos-c.pos;
vec1 = dot(vec0,c.view).*(c.view);
vec2 = vec1-vec0;
vec3 = dot(c.plane,vec0)*vec0;

figure(1);
% sphere(40);
% hold on;
scatter3([c.pos(1);s.pos(1)],[c.pos(2);s.pos(2)],[c.pos(3);s.pos(3)],'ko');
hold on;
plot3([c.pos(1),c.pos(1)+c.plane(1)],...
    [c.pos(2),c.pos(2)+c.plane(2)],...
    [c.pos(3),c.pos(3)+c.plane(3)]); % normal to plane
plot3([c.pos(1),c.pos(1)+vec0(1)],...
    [c.pos(2),c.pos(2)+vec0(2)],...
    [c.pos(3),c.pos(3)+vec0(3)]);
plot3([c.pos(1),c.pos(1)+vec1(1)],...
    [c.pos(2),c.pos(2)+vec1(2)],...
    [c.pos(3),c.pos(3)+vec1(3)]);
plot3([s.pos(1),s.pos(1)+vec2(1)],...
    [s.pos(2),s.pos(2)+vec2(2)],...
    [s.pos(3),s.pos(3)+vec2(3)]);
% plot3([c.pos(1),c.pos(1)+vec3(1)],...
%     [c.pos(2),c.pos(2)+vec3(2)],...
%     [c.pos(3),c.pos(3)+vec3(3)]);
hold off;





% figure(2);
temp = s.r(1)-c.pos;
y1 = 1;








