function circArrow = drawCircularArrow(radius,centre,sign,color)
%radius as a number
%centre as coordinates in format [x;y]
%for sign just sign(torque)
%color as 'g'

switch sign
    case 1 %angles for arrow in positive direction
        angles = linspace(-pi/2-0.7,pi/2+1,50);
    case -1
        angles = linspace(pi/2-1,3*pi/2+0.7);
end

x = radius*cos(angles);
y = radius*sin(angles);

x = centre(1) + x;
y = centre(2) + y;

x = [x,NaN];
y = [y,NaN];

%tip of arrow

ir = 0.9; %inner radius
ar = 1.1; %outer radius
thirdcorner = 0.3; %lastcorner of triangle

switch sign
    case 1
        ang = pi/2+1;
        xtip = [ir*radius*cos(ang),ar*radius*cos(ang),radius*cos(ang+thirdcorner)] + centre(1);
        ytip = [ir*radius*sin(ang),ar*radius*sin(ang),radius*sin(ang+thirdcorner)] + centre(2);
    case -1
        ang = pi/2-1;
        xtip = [ir*radius*cos(ang),ar*radius*cos(ang),radius*cos(ang-thirdcorner)] + centre(1);
        ytip = [ir*radius*sin(ang),ar*radius*sin(ang),radius*sin(ang-thirdcorner)] + centre(2);
end


patch(xtip,ytip,color,'EdgeColor',color);
patch(x,y,color,'EdgeColor',color,'LineWidth',1.5);
axis equal

end

