function [Model, status, Meldung, issues] = MatrizenStatik(inputSource, opts)
% Vereinheitlichter Orchestrator für die Berechnung 
% opts.mode         : "solve" (Standard) | "check" (nur Validierung, keine Berechnung)
% opts.renderOutput : logischer Wert (Standard true)

    if nargin < 2, opts = struct(); end
    opts = local_defaults(opts, struct( ...
        'mode',"solve", ...
        'renderOutput', true ...
    ));

    status  = 1;
    Meldung = '';
    issues  = struct([]);  % für zukünftige Erweiterungen (z. B. Warnungen)
    Model   = struct();

    try
        %% 0) Pfade minimal setzen
        here      = fileparts(mfilename('fullpath'));
        srcFolder = fileparts(here);
        projRoot  = fileparts(srcFolder);                      % project root

        addpath(srcFolder);                                    % src
        addpath(fullfile(srcFolder,'DSM'));                    % DSM root
        addpath(genpath(fullfile(srcFolder,'DSM')));           % alle DSM-Subfolder
        addpath(fullfile(srcFolder,'Main'));                   % Main
        addpath(fullfile(projRoot,'Beispiele'));               % <-- wichtig: Input .mlx

        %% 1) Input einlesen (gleiche Struktur von GUI oder Datei)
        if isnumeric(inputSource)
            % Input stammt aus einem Skript oder einer .m-Datei
            Model.Input = ModelVonInputFile(inputSource);
        elseif isstruct(inputSource)
            % Input stammt aus dem GUI und besitzt die gleiche Struktur wie die Inputfiles
            Model.Input = inputSource;
        else
            error('Ungültiger Input: erwartet wird eine Nummer oder eine Input-Struktur.');
        end

        %% 2) Umwandlung: Input → Analysemodell (zentrale Quelle der Wahrheit)
        Model.Analyse = inputUmwandeln(Model.Input);

        %% 3) Strikte Überprüfung auf Analyseebene
        Model.Analyse = sanitizeAnalysisModel(Model.Analyse, struct('strict',true));
        [okA, anaIssues] = validateAnalysisModel(Model.Analyse, struct('requireFullModel',true));
        issues = [issues, anaIssues]; %#ok<AGROW>
        if ~okA
            error('Analyse-Validierung fehlgeschlagen:\n%s', local_issuesToString(anaIssues));
        end

        %% 4) Optionale Vorbereitung für Einflusslinien
        if isfield(Model.Analyse,'gew_output') && Model.Analyse.gew_output == 2
            Model.Analyse = ModelFuerEinflusslinie(Model.Analyse);
        end

        %% 5) Nur-Check-Modus (z.B. für Unit-tests)
        if strcmpi(opts.mode,"check")
            return;
        end

        %% 6) Lösen (reine Mechanik, keine Ein-/Ausgabe)
        Model.Analyse = DirectStiffnessMethod(Model.Analyse);

        %% 7) Ergebnisse zusammenstellen + (optional) darstellen
        Model.Output = ZusammenSetzen(Model.Analyse);
        if opts.renderOutput
            OutputDarstellung(Model);
        end

    catch ME
        status  = -1;
        Meldung = ME.message;
    end
end

%% Helpers
function S = local_defaults(S, D)
    fn = fieldnames(D);
    for k = 1:numel(fn)
        f = fn{k};
        if ~isfield(S, f), S.(f) = D.(f); end
    end
end

function s = local_issuesToString(issues)
    if isempty(issues), s = ''; return; end
    if iscell(issues), s = strjoin(issues, newline); return; end
    lines = strings(0,1);
    for i = 1:numel(issues)
        it = issues(i);
        p  = getfield(it,'path', ''); %#ok<GFLD>
        sev= getfield(it,'severity',''); %#ok<GFLD>
        msg= getfield(it,'message',''); %#ok<GFLD>
        code=getfield(it,'code',''); %#ok<GFLD>
        lines(end+1) = sprintf('[%s] %s%s%s', sev, msg, ...
            ifelse(~isempty(code), " ("+code+")", ""), ...
            ifelse(~isempty(p),    " @ "+p, ""));
    end
    s = strjoin(cellstr(lines), newline);
end

function out = ifelse(cond, a, b)
    if cond, out = a; else, out = b; end
end
