function [out] = outputDarstellung(Model)

gew_output = Model.Analyse.gew_output;

switch gew_output
    case 1 %Schnittkräfte
        figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
        if isfield(Model, "Output") && isfield(Model.Output, "SKStab") ...
            && ~isempty(Model.Output.SKStab)
        drawSKFig(Model);
        end
        %figure('units', 'normalized', 'outerposition', [0.25, 0.25, 0.5, 0.5]);
        drawFig(Model);
    case 2 %Einflusslinie
        drawVLFig(Model);

    case 3 %Auflagerreaktionen
        drawAuflagerreaktionen(Model);
end

end
