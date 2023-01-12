function out = drawGelenk(type,centre,meanL)

switch type

    case 3
        radius = 0.025*meanL;
        angles = linspace(-pi,pi);
        
        x = radius*cos(angles) + centre(1);
        y = radius*sin(angles) + centre(2);
        
        
        patch(x,y,'w','LineWidth',1.1);
end

end

