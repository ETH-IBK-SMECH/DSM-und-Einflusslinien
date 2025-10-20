function feder = drawFeder(type, centre, L)
%type represents type of spring
%kord are the coordinates of node as [x;y]
%L is to normalize the supports with meanL


switch type
    case 1 
        x = [0,-0.02,-0.03,-0.05,-0.07,-0.09,-0.11,-0.13,-0.14,-0.15,-0.15,-0.15,NaN];
        y = [0,0,-0.02,0.02,-0.02,0.02,-0.02,0.02,0,0,-0.03,0.03,NaN];

        x = x*L*0.5;
        y = y*L*0.5;

        KORDS = centre + [x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 2 
        x = [0,0,-0.02,0.02,-0.02,0.02,-0.02,0.02,0,0,-0.03,0.03,NaN];
        y = [0,-0.02,-0.03,-0.05,-0.07,-0.09,-0.11,-0.13,-0.14,-0.15,-0.15,-0.15,NaN];
        
        x = x*L*0.5;
        y = y*L*0.5;

        KORDS = centre + [x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 3
        angles = linspace(pi,-2*pi-pi/4,100);
        radius = linspace(0,0.014,100);

        x = radius.*cos(angles);
        y = radius.*sin(angles);
        
        x = [x,0.018*cos(-2*pi-pi/4),0.018/cos(pi/6)*cos(-2*pi-pi/4-pi/6),0.018/cos(pi/6)*cos(-2*pi-pi/4+pi/6),NaN];
        y = [y,0.018*sin(-2*pi-pi/4),0.018/cos(pi/6)*sin(-2*pi-pi/4-pi/6),0.018/cos(pi/6)*sin(-2*pi-pi/4+pi/6),NaN];
    
        x = x*L;
        y = y*L;

        KORDS = centre + [x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

end


end

