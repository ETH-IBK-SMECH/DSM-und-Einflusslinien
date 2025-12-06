function [Model, status, Meldung, issues] = MatrizenStatik(inputSource, opts)
% Vereinheitlichter Orchestrator für die Berechnung
% opts.mode         : "solve" (Standard) | "check" (nur Validierung, keine Berechnung)
% opts.renderOutput : logischer Wert (Standard true)
warning off backtrace

if nargin < 2, opts = struct(); end
opts = local_defaults(opts, struct( ...
    'mode', "solve", ...
    'renderOutput', true ...
    ));

status = 1;
Meldung = '';
issues = {};
Model = struct();

try

    %% 1) Input einlesen
    Model.Input = inputSource;
    %% 2) Umwandlung: Input → Analysemodell
    Model.Analyse = inputUmwandeln(Model.Input);
    %% 3) Strikte Überprüfung auf Analyseebene
    Model.Analyse = sanitizeAnalysisModel(Model.Analyse, struct('strict', true));
    [okA, anaIssues] = validateAnalysisModel(Model.Analyse, struct('requireFullModel', true));
    issues = [issues, anaIssues(:).']; %#ok<AGROW>
    if ~okA
        error('Analyse-Validierung fehlgeschlagen:\n%s', local_issuesToString(anaIssues));
    end
    %% 4) Optionale Vorbereitung für Einflusslinien
    isEinfluss = isfield(Model.Analyse, 'gew_output') && Model.Analyse.gew_output == 2;

    if isEinfluss
        Model.Analyse = modelFuerEinflusslinie(Model.Analyse);
    end

    %% 5) Nur-Check-Modus (z.B. für Unit-tests)
    if strcmpi(opts.mode, "check")
        return;
    end

    %% 6) Lösen (reine Mechanik, keine Ein-/Ausgabe)
    Model.Analyse      = DirectStiffnessMethod(Model.Analyse);
    analyseForOutput   = Model.Analyse;

    %% 7) Ergebnisse zusammenstellen + (optional) darstellen
    Model.Output = zusammenSetzen(analyseForOutput);

    if opts.renderOutput
        outputDarstellung(Model);
    end
catch ME
    status = -1;
    %Meldung = ME.message;
    
    % Volle Fehlermeldung inkl. Stack in Meldung speichern
    Meldung = getReport(ME, 'extended', 'hyperlinks', 'on');

    % Zusätzlich direkt im Command Window anzeigen:
    fprintf(2, '%s\n', Meldung);  % 2 = stderr (rot im Command Window)

    % Optional: für Debug-Sessions trotzdem Fehler werfen
    if ~isfield(opts, 'suppressErrors') || ~opts.suppressErrors
        rethrow(ME); % oder: rethrowAsCaller(ME);
    end
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
if isempty(issues), s = '';
    return;
end
if iscell(issues), s = strjoin(issues, newline);
    return;
end
lines = strings(0, 1);
for i = 1:numel(issues)
    it = issues(i);
    p = getfield(it, 'path', ''); %#ok<GFLD>
    sev = getfield(it, 'severity', ''); %#ok<GFLD>
    msg = getfield(it, 'message', ''); %#ok<GFLD>
    code = getfield(it, 'code', ''); %#ok<GFLD>
    lines(end+1) = sprintf('[%s] %s%s%s', sev, msg, ...
        ifelse(~isempty(code), " ("+code+")", ""), ...
        ifelse(~isempty(p), " @ "+p, ""));
end
s = strjoin(cellstr(lines), newline);
end

function out = ifelse(cond, a, b)
if cond, out = a;
else, out = b;
end
end
