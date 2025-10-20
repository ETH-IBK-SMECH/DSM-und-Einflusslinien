function out = solveDSM(model)
    model = sanitizeAnalysisModel(model);
    [ok, issues] = validateAnalysisModel(model);
    if ~ok
        error('Analysemodell ist ungültig:\n%s', strjoin(issues, newline));
    end
    out = DirectStiffnessMethod(model); % solver expects clean input
end
