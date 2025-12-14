function [out] = outputDarstellung(Model)

gew_output = Model.Analyse.gew_output;

switch gew_output
    case 1 %Schnittkräfte
        figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
        if isfield(Model, "Output") && isfield(Model.Output, "SKStab") ...
            && ~isempty(Model.Output.SKStab)
        drawSKFig(Model);
        end
        %drawFig(Model);   % Uncomment if you want orig. system popup
    case 2 %Einflusslinie
        drawVLFig(Model);

    case 3 %Auflagerreaktionen
        drawAuflagerreaktionen(Model);
end

end
