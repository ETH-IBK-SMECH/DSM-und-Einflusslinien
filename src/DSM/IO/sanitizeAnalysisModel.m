function analysis = sanitizeAnalysisModel(analysis, opts)
% Sanitize (Analyse-Ebene)
% Ziel: Idempotente, harmlose Formatierungen und strukturelle Vollständigkeit.
%       KEINE stillen inhaltlichen Korrekturen (diese gehören in validate).
% Hinweise:
% - Felder werden angelegt, falls sie fehlen.
% - Legacy-Felder werden höchstens 1:1 gespiegelt (z. B. Feder.k → Feder.val, wenn sinnvoll).
% - Release-Indizes werden nur auf Vektorform/Einzigartigkeit gebracht (keine Physik-Heilung).

    if nargin < 2, opts = struct(); end

    % ---- Info / DOF pro Knoten (Default 3) ----
    if ~isfield(analysis,'Info') || ~isstruct(analysis.Info)
        analysis.Info = struct();
    end
    if ~isfield(analysis.Info,'nKnotenDOF') || ~isscalar(analysis.Info.nKnotenDOF) || ~isfinite(analysis.Info.nKnotenDOF)
        analysis.Info.nKnotenDOF = 3;
    end
    nDOFperNode = analysis.Info.nKnotenDOF;

    % ---- Pflichtfelder anlegen (typisierte leere Struct-Arrays) ----
    if ~isfield(analysis,'Knoten')     || isempty(analysis.Knoten),     analysis.Knoten     = struct('x',{},'y',{}); end
    if ~isfield(analysis,'Stab')       || isempty(analysis.Stab),       analysis.Stab       = struct('sNode',{},'eNode',{},'E',{},'A',{},'Iy',{},'sRelease',{},'eRelease',{},'inTeilSys',{}); end
    if ~isfield(analysis,'Teilsystem') || isempty(analysis.Teilsystem), analysis.Teilsystem = struct('BeteiligteStaebe',{},'KnotenDesTS',{},'KnotenTSgeordnet',{}); end
    if ~isfield(analysis,'Feder')      || isempty(analysis.Feder),      analysis.Feder      = struct('node',{},'dir',{},'val',{}); end
    if ~isfield(analysis,'KnotenLast') || isempty(analysis.KnotenLast), analysis.KnotenLast = struct('node',{},'dir',{},'val',{}); end
    if ~isfield(analysis,'StabLast')   || isempty(analysis.StabLast),   analysis.StabLast   = struct('stab',{},'typ',{},'sDist',{},'eDist',{},'val',{},'dir',{}); end
    if ~isfield(analysis,'SPC')        || isempty(analysis.SPC),        analysis.SPC        = struct('node',{},'dir',{},'val',{}); end


    % ---- Knoten: keine Werteänderung, nur sicherstellen, dass Structs vorliegen ----
    % (Konvertierungen von GUI-Tabellen → Structs sollten bereits in inputUmwandeln passieren.)

    % ---- Stäbe: Release-Felder zu eindeutigen Zeilenvektoren formen (nur Form) ----
    for i = 1:numel(analysis.Stab)
        if ~isfield(analysis.Stab(i),'sRelease') || isempty(analysis.Stab(i).sRelease), analysis.Stab(i).sRelease = []; end
        if ~isfield(analysis.Stab(i),'eRelease') || isempty(analysis.Stab(i).eRelease), analysis.Stab(i).eRelease = []; end
        % Nur Form (Zeilenvektor, unique).
        analysis.Stab(i).sRelease = unique(analysis.Stab(i).sRelease(:)'); %#ok<AGROW>
        analysis.Stab(i).eRelease = unique(analysis.Stab(i).eRelease(:)'); %#ok<AGROW>
        % Sicherstellen, dass sNode/eNode-Felder existieren (Werteprüfung macht validate)
        if ~isfield(analysis.Stab(i),'sNode'), analysis.Stab(i).sNode = NaN; end
        if ~isfield(analysis.Stab(i),'eNode'), analysis.Stab(i).eNode = NaN; end
    end

    % ---- Federn: Legacy .k → .val spiegeln ----
    for i = 1:numel(analysis.Feder)
        if ~isfield(analysis.Feder(i),'node'), analysis.Feder(i).node = NaN; end
        if ~isfield(analysis.Feder(i),'dir'),  analysis.Feder(i).dir  = NaN; end
        % val aus k übernehmen, falls val fehlt und k vorhanden
        if ~isfield(analysis.Feder(i),'val') && isfield(analysis.Feder(i),'k')
            analysis.Feder(i).val = analysis.Feder(i).k;
        elseif ~isfield(analysis.Feder(i),'val')
            analysis.Feder(i).val = NaN;
        end
    end

    % ---- Knotenlasten: Felder sicherstellen ----
    for i = 1:numel(analysis.KnotenLast)
        if ~isfield(analysis.KnotenLast(i),'node'), analysis.KnotenLast(i).node = NaN; end
        if ~isfield(analysis.KnotenLast(i),'dir'),  analysis.KnotenLast(i).dir  = NaN; end
        if ~isfield(analysis.KnotenLast(i),'val'),  analysis.KnotenLast(i).val  = NaN; end
    end

    % ---- Stablasten: Standardfelder komplettieren ----
    for i = 1:numel(analysis.StabLast)
        if ~isfield(analysis.StabLast(i),'stab'),  analysis.StabLast(i).stab  = NaN; end
        if ~isfield(analysis.StabLast(i),'typ'),   analysis.StabLast(i).typ   = NaN; end
        if ~isfield(analysis.StabLast(i),'sDist'), analysis.StabLast(i).sDist = 0;   end
        if ~isfield(analysis.StabLast(i),'eDist'), analysis.StabLast(i).eDist = analysis.StabLast(i).sDist; end
    end

    % ---- SPC: Felder sicherstellen ----
    for i = 1:numel(analysis.SPC)
        if ~isfield(analysis.SPC(i),'node'), analysis.SPC(i).node = NaN; end
        if ~isfield(analysis.SPC(i),'dir'),  analysis.SPC(i).dir  = NaN; end
        if ~isfield(analysis.SPC(i),'val'),  analysis.SPC(i).val  = NaN; end
    end

    % ---- Teilsystem-Struktur vervollständigen ----
    for t = 1:numel(analysis.Teilsystem)
        if ~isfield(analysis.Teilsystem(t),'BeteiligteStaebe'), analysis.Teilsystem(t).BeteiligteStaebe = []; end
        if ~isfield(analysis.Teilsystem(t),'KnotenDesTS'),      analysis.Teilsystem(t).KnotenDesTS      = []; end
        if ~isfield(analysis.Teilsystem(t),'KnotenTSgeordnet'), analysis.Teilsystem(t).KnotenTSgeordnet = []; end
    end

    % ---- Abgeleitete Info-Werte (nur Zähler, keine Logik) ----
    analysis.Info.nKnoten       = numel(analysis.Knoten);
    analysis.Info.nStaebe       = numel(analysis.Stab);
    analysis.Info.nTeilsys      = numel(analysis.Teilsystem);
    analysis.Info.nFedern       = numel(analysis.Feder);
    analysis.Info.nKnotenLasten = numel(analysis.KnotenLast);
    analysis.Info.nStabLasten   = numel(analysis.StabLast);
    analysis.Info.nSPC          = numel(analysis.SPC);

    % ---- Markierung inTeilSys (nur Flag setzen) ----
    for i = 1:analysis.Info.nStaebe
        analysis.Stab(i).inTeilSys = false;
    end
    for t = 1:analysis.Info.nTeilsys
        bs = [];
        if isfield(analysis.Teilsystem(t),'BeteiligteStaebe')
            bs = analysis.Teilsystem(t).BeteiligteStaebe(:)';
        end
        bs = bs(bs>=1 & bs<=analysis.Info.nStaebe);
        for s = bs, analysis.Stab(s).inTeilSys = true; end
    end

    % ---- Knotenlisten je Teilsystem ----
    for t = 1:analysis.Info.nTeilsys
        bs = analysis.Teilsystem(t).BeteiligteStaebe(:)';
        bs = bs(bs>=1 & bs<=analysis.Info.nStaebe);
        if isempty(bs)
            analysis.Teilsystem(t).KnotenDesTS      = [];
            analysis.Teilsystem(t).KnotenTSgeordnet = [];
            continue;
        end
        nS = numel(bs);
        KDes = zeros(2*nS,1);
        for j = 1:nS
            sIdx = bs(j);
            KDes(2*j-1) = safeIndex(analysis.Stab, sIdx, 'sNode');
            KDes(2*j)   = safeIndex(analysis.Stab, sIdx, 'eNode');
        end
        analysis.Teilsystem(t).KnotenDesTS = KDes;
        if exist('getKnotenTS','file') == 2
            analysis.Teilsystem(t).KnotenTSgeordnet = getKnotenTS(KDes, nS);
        else
            analysis.Teilsystem(t).KnotenTSgeordnet = unique(KDes,'stable');
        end
    end
end

% local helper 
function v = safeIndex(arr, idx, field)
    v = NaN;
    if idx>=1 && idx<=numel(arr) && isfield(arr(idx),field)
        vv = arr(idx).(field);
        if isscalar(vv), v = vv; end
    end
end
