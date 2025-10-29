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
    if ~isfield(analysis,'Stab')       || isempty(analysis.Stab),       analysis.Stab       = struct('sNode',{},'eNode',{},'E',{},'A',{},'Iy',{},'sRelease',{},'eRelease',{}); end
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

    % ---- Abgeleitete Info-Werte (nur Zähler, keine Logik) ----
    analysis.Info.nKnoten       = numel(analysis.Knoten);
    analysis.Info.nStaebe       = numel(analysis.Stab);
    analysis.Info.nFedern       = numel(analysis.Feder);
    analysis.Info.nKnotenLasten = numel(analysis.KnotenLast);
    analysis.Info.nStabLasten   = numel(analysis.StabLast);
    analysis.Info.nSPC          = numel(analysis.SPC);

    % ---- Kondensation (optional) ----
    if ~isfield(analysis, 'Kondensation') || isempty(analysis.Kondensation)
        analysis.Kondensation = [];   % absence means: no condensation
    else
        K = analysis.Kondensation;
        if ~isfield(K,'Knoten') || isempty(K.Knoten)
            K.Knoten = [];
        else
            K.Knoten = unique(K.Knoten(:)).';  % row, unique
        end
        if ~isfield(K,'KomponentenMaske') || isempty(K.KomponentenMaske)
            K.KomponentenMaske = false(1, analysis.Info.nKnotenDOF);
        else
            K.KomponentenMaske = logical( K.KomponentenMaske(:).' ); % row logical
            % If wrong length, pad/truncate non-destructively (true sanitize)
            if numel(K.KomponentenMaske) ~= analysis.Info.nKnotenDOF
                m = false(1, analysis.Info.nKnotenDOF);
                m(1:min(end, numel(K.KomponentenMaske))) = K.KomponentenMaske(1:min(end, numel(K.KomponentenMaske)));
                K.KomponentenMaske = m;
            end
        end
        analysis.Kondensation = K;
    end
    
    for i = 1:numel(analysis.Stab)
        if ~isfield(analysis.Stab(i),'activeStabDOF') || isempty(analysis.Stab(i).activeStabDOF)
            analysis.Stab(i).activeStabDOF = true(1, 2*analysis.Info.nKnotenDOF);
        else
            a = logical(analysis.Stab(i).activeStabDOF(:).');
            if numel(a) ~= 2*analysis.Info.nKnotenDOF
                b = true(1, 2*analysis.Info.nKnotenDOF);
                b(1:min(end,numel(a))) = a(1:min(end,numel(a)));
                analysis.Stab(i).activeStabDOF = b;
            else
                analysis.Stab(i).activeStabDOF = a;
            end
        end
    end

end

