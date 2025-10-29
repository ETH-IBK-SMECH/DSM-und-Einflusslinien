function out = it_run_main(M)
% tests.util.it_run_main  Mirror MatrizenStatik + DirectStiffnessMethod,
% but light-weight for tests.
% Input/Output: analysis-model-like struct as in your code.

    % 1) Strict sanitize + validate (like MatrizenStatik)
    M = sanitizeAnalysisModel(M, struct('strict',true));
    [okA, issues] = validateAnalysisModel(M, struct('requireFullModel',true));
    if ~okA
        error('Analyse-Validierung fehlgeschlagen: %s', 'see issues');
    end

    % 2) Optional EL preparation (like MatrizenStatik)
    if isfield(M,'gew_output') && M.gew_output == 2
        M = modelFuerEinflusslinie(M);
    end

    % 3) Run the real DSM pipeline
    out = DirectStiffnessMethod(M);
end
