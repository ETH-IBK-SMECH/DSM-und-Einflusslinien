function [out] = OutputDarstellung(Model)

gew_output = Model.Analyse.gew_output;

switch gew_output
    case 1 %Schnittkräfte
        drawSKFig(Model);

    case 2 %Einflusslinie
        drawVLFig(Model);

    case 3 %Auflagerreaktionen
        drawAuflagerreaktionen(Model);
end

end

