function [ok, issues] = validateAnalysisModel(A, opts)
% Validate (Analyse-Ebene)
% Ziel: Strikte, modellweite Prüfung der Selbstkonsistenz; KEINE Mutationen.
% Rückgabe:
%   ok     : true, wenn keine ERRORs gefunden wurden
%   issues : cellstr mit deutschsprachigen Fehlermeldungen

if nargin < 2, opts = struct(); end
issues = {};
tol = 1e-12;

% ---- Grundstruktur vorhanden? ----
need = {'Knoten', 'Stab', 'SPC', 'Info'};
for k = 1:numel(need)
    if ~isfield(A, need{k})
        issues{end+1} = sprintf('ERROR: Feld A.%s fehlt.', need{k});
    end
end
if ~isempty(issues), ok = false;
    return;
end

% ---- DOF pro Knoten plausibel? ----
if ~isfield(A.Info, 'nKnotenDOF') || ~isscalar(A.Info.nKnotenDOF) || ~isfinite(A.Info.nKnotenDOF)
    issues{end+1} = 'ERROR: Info.nKnotenDOF ist ungültig (endlicher Skalar erwartet).';
    ndof = 3;
else
    ndof = A.Info.nKnotenDOF;
end

% ---- Knoten prüfen ----
nK = numel(A.Knoten);
if numel(A.Stab) > 0 && nK < 2
    issues{end+1} = 'ERROR: Mindestens zwei Knoten erforderlich, wenn Stäbe vorhanden sind.';
end
for i = 1:nK
    if ~isfield(A.Knoten(i), 'x') || ~isfield(A.Knoten(i), 'y') ...
            || ~isscalar(A.Knoten(i).x) || ~isscalar(A.Knoten(i).y) ...
            || ~isfinite(A.Knoten(i).x) || ~isfinite(A.Knoten(i).y)
        issues{end+1} = sprintf('ERROR: Knoten %d hat ungültige Koordinaten.', i);
    end
end

% ---- Knoten mit identischen Koordinaten erkennen ----
if nK > 1
    x = arrayfun(@(K) K.x, A.Knoten(:));
    y = arrayfun(@(K) K.y, A.Knoten(:));

    XY   = [x(:), y(:)];
    tolC = 1e-12;  % oder etwas grösser, falls nötig

    % Paare mit "praktisch gleichen" Koordinaten finden
    for i = 1:nK-1
        for j = i+1:nK
            if hypot(XY(i,1) - XY(j,1), XY(i,2) - XY(j,2)) < tolC
                issues{end+1} = sprintf( ...
                    'ERROR: Knoten %d und %d haben identische Koordinaten (doppelte Knoten).', ...
                    i, j);
            end
        end
    end
end


% ---- Stäbe prüfen ----
for i = 1:numel(A.Stab)
    s = A.Stab(i);
    req = {'sNode', 'eNode', 'E', 'A', 'Iy'};
    for r = 1:numel(req)
        if ~isfield(s, req{r})
            issues{end+1} = sprintf('ERROR: Stab(%d): Feld "%s" fehlt.', i, req{r});
        end
    end
    if ~isfield(s, 'sNode') || ~isfield(s, 'eNode') || ~isfinite(s.sNode) || ~isfinite(s.eNode)
        issues{end+1} = sprintf('ERROR: Stab(%d): sNode/eNode fehlen oder sind ungültig.', i);
        continue;
    end
    if ~(s.sNode >= 1 && s.sNode <= nK) || ~(s.eNode >= 1 && s.eNode <= nK)
        issues{end+1} = sprintf('ERROR: Stab(%d): sNode/eNode außerhalb des gültigen Bereichs.', i);
    elseif s.sNode == s.eNode
        issues{end+1} = sprintf('ERROR: Stab(%d): Start- und Endknoten sind identisch.', i);
    else
        L = hypot(A.Knoten(s.eNode).x-A.Knoten(s.sNode).x, ...
            A.Knoten(s.eNode).y-A.Knoten(s.sNode).y);
        if ~isfinite(L) || L < tol
            issues{end+1} = sprintf('ERROR: Stab(%d) besitzt (nahezu) Null-Länge.', i);
        end
    end
    % Material/Geometrie > 0
    if ~isfield(s, 'E') || ~isfinite(s.E) || ~(s.E > 0), issues{end+1} = sprintf('ERROR: Stab(%d): E muss > 0 sein.', i); end
    if ~isfield(s, 'A') || ~isfinite(s.A) || ~(s.A > 0), issues{end+1} = sprintf('ERROR: Stab(%d): A muss > 0 sein.', i); end
    if ~isfield(s, 'Iy') || ~isfinite(s.Iy) || ~(s.Iy > 0), issues{end+1} = sprintf('ERROR: Stab(%d): Iy muss > 0 sein.', i); end
    % Releases: nur gültige DOF-Indizes 1..ndof zulässig
    for relf = {'sRelease', 'eRelease'}
        if isfield(s, relf{1}) && ~isempty(s.(relf{1}))
            bad = s.(relf{1})(~ismember(s.(relf{1}), 1:ndof));
            if ~isempty(bad)
                issues{end+1} = sprintf('ERROR: Stab(%d): %s enthält ungültige DOF-Indizes.', i, relf{1});
            end
        end
    end
end

% ---- Mehrere Stäbe zwischen denselben Knoten erkennen ----
if numel(A.Stab) > 1
    % Nur Stäbe mit gültigen Knotenindizes betrachten
    validMask = false(1, numel(A.Stab));
    for i = 1:numel(A.Stab)
        s = A.Stab(i);
        if isfield(s, 'sNode') && isfield(s, 'eNode') && ...
                isfinite(s.sNode) && isfinite(s.eNode) && ...
                s.sNode >= 1 && s.sNode <= nK && ...
                s.eNode >= 1 && s.eNode <= nK
            validMask(i) = true;
        end
    end

    beamIdx = find(validMask);
    if ~isempty(beamIdx)
        sNodes = [A.Stab(validMask).sNode];
        eNodes = [A.Stab(validMask).eNode];

        % (1,2) und (2,1) sollen als gleich gelten -> Enden sortieren
        ends = sort([sNodes; eNodes], 1).'; % n x 2

        % Gleiche (sNode,eNode)-Paare finden
        [uniquePairs, ~, ic] = unique(ends, 'rows');
        counts = accumarray(ic, 1);

        dupGroups = find(counts > 1); % Indizes der Paare, die mehrfach vorkommen

        for g = dupGroups.'
            % Alle Stäbe, die dieses Knotenpaar haben
            theseBeams = beamIdx(ic == g);
            k1 = uniquePairs(g, 1);
            k2 = uniquePairs(g, 2);

            issues{end+1} = sprintf( ...
                'ERROR: Mehrere Stäbe zwischen denselben Knoten (%d–%d): Stäbe [%s].', ...
                k1, k2, num2str(theseBeams));
        end
    end
end


% ---- Lager (SPC) prüfen ----
if isempty(A.SPC)
    issues{end+1} = 'ERROR: Keine Lager (SPC) definiert – System vermutlich kinematisch.';
end
for i = 1:numel(A.SPC)
    C = A.SPC(i);
    if ~isfield(C, 'node') || ~isfinite(C.node) || ~(C.node >= 1 && C.node <= nK)
        issues{end+1} = sprintf('ERROR: SPC %d: Knotenindex ungültig.', i);
    end
    if ~isfield(C, 'dir') || ~isscalar(C.dir) || ~ismember(C.dir, 1:ndof)
        issues{end+1} = sprintf('ERROR: SPC %d: dir muss in 1..%d liegen.', i, ndof);
    end
    if ~isfield(C, 'val') || ~isfinite(C.val)
        issues{end+1} = sprintf('ERROR: SPC %d: val fehlt/ungültig.', i);
    end
end

% ---- Mehrere Lagerbedingungen am selben Knoten / DOF erkennen ----

if ~isempty(A.SPC)
    if isfield(A.SPC, 'val')
        vals = [A.SPC.val];          
    else
        vals = zeros(size(A.SPC));
    end

    tol = 1e-12;                      % kleine Toleranz für "gleich 0"
    isDirichlet = abs(vals) < tol;

    SPC0 = A.SPC(isDirichlet);        % nur u=0-SPCs
    if ~isempty(SPC0)
        nodes = [SPC0.node];
        dirs  = [SPC0.dir];

        % Nur gültige Indizes betrachten
        valid = isfinite(nodes) & isfinite(dirs) & ...
            nodes >= 1 & nodes <= nK & ...
            dirs  >= 1 & dirs  <= ndof;

        nodes = nodes(valid);
        dirs  = dirs(valid);

        if ~isempty(nodes)
            % Alle (node, dir)-Paare
            pairs = [nodes(:), dirs(:)];          % N x 2

            % Mehrfach vorkommende Paare finden
            [uniqPairs, ~, ic] = unique(pairs, 'rows');
            counts = accumarray(ic, 1);

            dupIdx = find(counts > 1);
            for j = dupIdx.'
                k = uniqPairs(j, 1);
                d = uniqPairs(j, 2);
                warning('Mehrere Lagerbedingungen am selben Knoten und in derselben Richtung (Knoten %d, Richtung %d).', ...
                    k, d);
            end
        end
    end
end

% ---- Federn prüfen ----
for i = 1:numel(A.Feder)
    S = A.Feder(i);
    if ~isfield(S, 'node') || ~isfinite(S.node) || ~(S.node >= 1 && S.node <= nK)
        issues{end+1} = sprintf('ERROR: Feder %d: Knotenindex ungültig.', i);
    end
    if ~isfield(S, 'dir') || ~isscalar(S.dir) || ~ismember(S.dir, 1:ndof)
        issues{end+1} = sprintf('ERROR: Feder %d: dir muss in 1..%d liegen.', i, ndof);
    end
    if ~isfield(S, 'val') || ~isfinite(S.val) || ~(S.val >= 0)
        issues{end+1} = sprintf('ERROR: Feder %d: Steifigkeit val muss ≥ 0 sein.', i);
    end
end

% ---- Knotenlasten prüfen ----
for i = 1:numel(A.KnotenLast)
    L = A.KnotenLast(i);
    if ~isfield(L, 'node') || ~isfinite(L.node) || ~(L.node >= 1 && L.node <= nK)
        issues{end+1} = sprintf('ERROR: Knotenlast %d: Knotenindex ungültig.', i);
    end
    if ~isfield(L, 'dir') || ~isscalar(L.dir) || ~ismember(L.dir, 1:ndof)
        issues{end+1} = sprintf('ERROR: Knotenlast %d: dir muss in 1..%d liegen.', i, ndof);
    end
    if ~isfield(L, 'val') || ~isfinite(L.val)
        issues{end+1} = sprintf('ERROR: Knotenlast %d: val fehlt/ungültig.', i);
    end
end

% ---- Stablasten prüfen (Minimalregeln) ----
allowedTyp = [1, 2, 3, 4, 5, 6];
for i = 1:numel(A.StabLast)
    SL = A.StabLast(i);
    if ~isfield(SL, 'stab') || ~isfinite(SL.stab) || ~(SL.stab >= 1 && SL.stab <= numel(A.Stab))
        issues{end+1} = sprintf('ERROR: Stab/Verteile Last %d: Stabindex ungültig.', i);
    end
    if ~isfield(SL, 'typ') || ~ismember(SL.typ, allowedTyp)
        issues{end+1} = sprintf('ERROR: Stab/Verteilte Last %d: unbekannter Typ (erlaubt: [%s]).', ...
            i, sprintf('%d ', allowedTyp));
    end
    % Optional: sDist/eDist in [0,1] (falls als Längenanteil definiert)
    if isfield(SL, 'sDist') && ~isempty(SL.sDist) && (~isfinite(SL.sDist) || SL.sDist < 0 || SL.sDist > 1)
        issues{end+1} = sprintf('ERROR: Stab/Verteilte Last %d: sDist muss in [0,1] liegen.', i);
    end
    if isfield(SL, 'eDist') && ~isempty(SL.eDist) && (~isfinite(SL.eDist) || SL.eDist < 0 || SL.eDist > 1)
        issues{end+1} = sprintf('ERROR: Stab/Verteilte Last %d: eDist muss in [0,1] liegen.', i);
    end
end

% ---- Isolierte / ungenutzte Knoten erkennen ----
if nK > 0
    used = false(nK,1);

    % Stäbe
    for i = 1:numel(A.Stab)
        s = A.Stab(i);
        if isfield(s,'sNode') && isfinite(s.sNode) && s.sNode >= 1 && s.sNode <= nK
            used(s.sNode) = true;
        end
        if isfield(s,'eNode') && isfinite(s.eNode) && s.eNode >= 1 && s.eNode <= nK
            used(s.eNode) = true;
        end
    end

    % Federn
    for i = 1:numel(A.Feder)
        S = A.Feder(i);
        if isfield(S,'node') && isfinite(S.node) && S.node >= 1 && S.node <= nK
            used(S.node) = true;
        end
    end

    % SPC
    for i = 1:numel(A.SPC)
        C = A.SPC(i);
        if isfield(C,'node') && isfinite(C.node) && C.node >= 1 && C.node <= nK
            used(C.node) = true;
        end
    end

    % Knotenlasten
    for i = 1:numel(A.KnotenLast)
        L = A.KnotenLast(i);
        if isfield(L,'node') && isfinite(L.node) && L.node >= 1 && L.node <= nK
            used(L.node) = true;
        end
    end

    % Knoten, die nirgends verwendet werden
    unusedNodes = find(~used);

    if ~isempty(unusedNodes)
        % als Warnung behandeln:

        
            warning(['Die folgenden Knoten sind ungenutzt (kein Stab, keine Feder, kein Lager, keine Last): ', ...
            num2str(unusedNodes)]);
    end
end


% ---- Kondensation prüfen ----
if isfield(A, 'Kondensation') && ~isempty(A.Kondensation)
    K = A.Kondensation;

    % Knoten
    if ~isfield(K, 'Knoten') || ~isvector(K.Knoten)
        issues{end+1} = 'ERROR: Kondensation.Knoten muss ein Vektor mit Knoten-IDs sein.';
    else
        nodesK = K.Knoten(:);
        bad = nodesK(~ismember(nodesK, 1:numel(A.Knoten)));
        if ~isempty(bad)
            issues{end+1} = sprintf( ...
                'ERROR: Kondensation.Knoten enthält ungültige Knoten-IDs: [%s].', ...
                num2str(bad.'));
        end
    end

    % KomponentenMaske
    if ~isfield(K, 'KomponentenMaske') || ~islogical(K.KomponentenMaske)
        issues{end+1} = 'ERROR: Kondensation.KomponentenMaske muss logisch sein.';
    else
        M = K.KomponentenMaske;
        if size(M,2) ~= ndof
            issues{end+1} = sprintf( ...
                'ERROR: Kondensation.KomponentenMaske muss %d Spalten (DOF pro Knoten) haben.', ndof);
        end
        if size(M,1) ~= numel(K.Knoten)
            issues{end+1} = 'ERROR: Kondensation.KomponentenMaske muss gleich viele Zeilen wie Knoten-Einträge haben.';
        end
    end
end


ok = isempty(issues);
end
