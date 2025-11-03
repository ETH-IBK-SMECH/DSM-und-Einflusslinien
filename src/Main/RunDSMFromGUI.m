function [Model, status, msgs, warns] = RunDSMFromGUI(gui, outputType)
%% TODO
msgs = {};
warns = {};
% 1) GUI sanitize + validate (fast, field-level)
guiNorm = sanitizeGuiModel(gui);
[okGUI, issuesGUI] = validateGuiModel(guiNorm);
if ~okGUI, status = -1;
    msgs = issuesGUI;
    Model = struct();
    return;
end

% 2) Map
A = guiToAnalysis(guiNorm);

% 3) Analysis sanitize + validate (domain rules)
A = sanitizeAnalysisModel(A);
[okA, issuesA] = validateAnalysisModel(A);
if ~okA, status = -1;
    msgs = issuesA;
    Model = struct();
    return;
end

% 4) Solve (with try/catch)
try
    A.gew_output = outputType;
    % if needed: A = prepareForOutput(A, outputType);
    Model = DirectStiffnessMethod(A);
    status = 0;
catch ME
    status = -1;
    msgs = {ME.message};
    Model = struct();
end
end
