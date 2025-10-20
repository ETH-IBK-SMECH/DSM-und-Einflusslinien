function lager = drawLager(type, centre, R, L)
%type represents type of support
%kord are the coordinates of node as [x;y]
%R will be needed to rotate
%L is to normalize the supports with meanL


switch type
    case 1 %einspannung
        x = [0,0,-0.05,0,0,-0.05,0,0,-0.05,0,0,0,NaN];
        y = [0,0.1,1/30,0.1,1/30,-1/30,1/30,-1/30,-0.1,-1/30,-0.1,0,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 2 %gelenkiges auflager
        x = [0,0.1,-0.1,0,NaN];
        y = [0,-0.13,-0.13,0,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 3
        x = [0,0.1,-0.1,0,NaN,-0.1,0.1,NaN];
        y = [0,-0.13,-0.13,0,NaN,-0.165,-0.165,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 4
        x = [0,-0.13,-0.13,0,NaN,-0.155,-0.155,NaN];
        y = [0,0.1,-0.1,0,NaN,-0.1,0.1,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 5 
        x = [0,-0.1,0.1,NaN,0.1,-0.1,NaN];
        y = [0,0,0,NaN,-0.05,-0.05,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

    case 6
        x = [0,0,0,NaN,-0.05,-0.05,NaN];
        y = [0,-0.1,0.1,NaN,0.1,-0.1,NaN];

        x = x*L;
        y = y*L;

        KORDS = centre + R'*[x;y];

        patch(KORDS(1,:),KORDS(2,:),'k','LineWidth',1);
        axis equal;

end


end

