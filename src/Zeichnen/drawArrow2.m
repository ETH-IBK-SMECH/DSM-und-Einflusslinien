function arrow = drawArrow2(p0,p1,color,l)
%p0 are coordinates of tail as [x;y]
%p1 are coordinates of tip as [x;y]
%color as 'g'

%spike gad do drii schriibe zum patche
patch([p0(1),p1(1)], [p0(2),p1(2)], color,'EdgeColor',color,'LineWidth',1.5);

%now spike in dependence of tip position and angle

%length usrächne
%winku usrächne
dx = p1(1) - p0(1);
dy = p1(2) - p0(2);
l = l*0.2;


%spitz chunnt bi p1
xKoord = [0,-0.1*l,-0.1*l];
yKoord = [0,0.06*l,-0.06*l];

len = sqrt(dx*dx + dy*dy);
c = dx/len;
s = dy/len;
R = [c,s;-s,c];

tipKoord = R'*[xKoord;yKoord] + p1;

patch(tipKoord(1,:),tipKoord(2,:),color,'EdgeColor',color);
axis equal;




end

