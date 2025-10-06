function [Model, status, msgs] = solveDSM(guiOrAnalysis, outputType)
% outputType: 1=SK, 2=EL, 3=Reactions
% Returns: Model (struct of results), status (0 ok / -1 error), msgs (cellstr)

    msgs = {};
    try
        % 1) Map into your analysis format if caller passed a GUI struct
        if isfield(guiOrAnalysis, 'Nodes') 
            analysisModel = guiToAnalysis(guiOrAnalysis);
        else
            analysisModel = guiOrAnalysis;  % already in analysis format
        end

        % 2) Validate early 
        [ok, issues] = validateAnalysisModel(analysisModel);
        if ~ok
            status = -1; msgs = issues; Model = struct(); return;
        end

        % 3) Run solver
        analysisModel.gew_output = outputType;
        out = DirectStiffnessMethod(analysisModel);

        % 4) Compose result package
        Model = out;
        status = 0;

    catch ME
        status = -1;
        msgs = {ME.message};
        Model = struct();
    end
end
