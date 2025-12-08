function [out] = drawOriginalFig(Model)

% Darstellung basierend auf Model.Analyse mit Lager-Typen aus Model.Input
% Knoten
Ktab = Model.Input.Knoten;
if istable(Ktab)
    Knoten = table2struct(Ktab);
else
    % falls schon struct mit x / y:
    Knoten = Ktab;
end

% sicherstellen, dass xPos/yPos existieren
if isfield(Knoten, 'x') && ~isfield(Knoten, 'xPos')
    for i = 1:numel(Knoten)
        Knoten(i).xPos = Knoten(i).x;
        Knoten(i).yPos = Knoten(i).y;
    end
end
nKnoten = numel(Knoten);

% Analyse-Stäbe behalten wir separat (für EIinf, Releases usw.)
Stab = Model.Analyse.Stab;

% Staebe = Original-Stäbe aus dem Input
StabTab = Model.Input.Staebe;
if istable(StabTab)
    StabTab = table2struct(StabTab);
end
nStaebe = numel(StabTab);

Staebe = struct( ...
    'StartKnoten', num2cell([StabTab.StartKnoten]), ...
    'EndKnoten',   num2cell([StabTab.EndKnoten]));

% Lager: bleiben aus dem Input
Lager = Model.Input.Lager;

Feder    = Model.Analyse.Feder;      % struct mit .node, .dir, .val
KnotenLast = Model.Analyse.KnotenLast; % struct mit .node, .dir, .val
StabLast   = Model.Analyse.StabLast;   % struct mit .stab, .dir, .val, .sDist, .eDist, .typ

meanL = mean([Stab.L]);

% StabLast_konz und StabLast_vert aus Analysemodell bauen
StabLast_konz = struct('Stab', {}, 'Richtung', {}, 'Wert', {}, ...
    'StartPosition', {}, 'EndPosition', {});
StabLast_vert = struct('Stab', {}, 'Richtung', {}, 'Wert', {}, ...
    'StartPosition', {}, 'EndPosition', {});

for i = 1:numel(StabLast)
    isDistributed = ~isempty(StabLast(i).eDist); % eDist leer = konzentriert

    if isDistributed
        idx = numel(StabLast_vert) + 1;
        StabLast_vert(idx).Stab           = StabLast(i).stab;
        StabLast_vert(idx).Richtung       = StabLast(i).dir;
        StabLast_vert(idx).Wert           = StabLast(i).val;
        StabLast_vert(idx).StartPosition  = StabLast(i).sDist;
        StabLast_vert(idx).EndPosition    = StabLast(i).eDist;
    else
        idx = numel(StabLast_konz) + 1;
        StabLast_konz(idx).Stab           = StabLast(i).stab;
        StabLast_konz(idx).Richtung       = StabLast(i).dir;
        StabLast_konz(idx).Wert           = StabLast(i).val;
        StabLast_konz(idx).StartPosition  = StabLast(i).sDist;
        StabLast_konz(idx).EndPosition    = [];
    end
end

% mean konzentrierte Stablasten -> beachte, dass Moment in kNmm erfasst wird
if ~isempty(StabLast_konz) && isfield(StabLast_konz, 'Wert')
    formeanSLk = [];
    for i = 1:numel(StabLast_konz)
        if StabLast_konz(i).Richtung == 3
            formeanSLk(end+1) = StabLast_konz(i).Wert / 1000;
        else
            formeanSLk(end+1) = StabLast_konz(i).Wert;
        end
    end
    meanSLk = abs(mean(abs(formeanSLk)));
else
    meanSLk = 1;
end

% mean verteilte Stablasten
if ~isempty(StabLast_vert) && isfield(StabLast_vert, 'Wert')
    formeanSLv = [];
    for i = 1:numel(StabLast_vert)
        if StabLast_vert(i).Richtung == 3
            formeanSLv(end+1) = StabLast_vert(i).Wert / 1000;
        else
            formeanSLv(end+1) = StabLast_vert(i).Wert;
        end
    end
    meanSLv = abs(mean(abs(formeanSLv)));
else
    meanSLv = 1;
end

% mean Knotenlasten
if ~isempty(KnotenLast) && isfield(KnotenLast, 'val')
    formeanKL = [];
    nKL = numel(KnotenLast);
    for i = 1:nKL
        if KnotenLast(i).dir == 3
            formeanKL(end+1) = KnotenLast(i).val / 1000;
        else
            formeanKL(end+1) = KnotenLast(i).val;
        end
    end
    meanKL = abs(mean(abs(formeanKL)));
else
    meanKL = 1;
    nKL = 0;
end

% ==== Ab hier nur noch Zeichnen: aufteilen in drawOriginalXY-Funktionen ====

% 1) Stäbe (mit L, c, s, R) zeichnen
Staebe = drawOriginalBeams(Knoten, Staebe);

% 2) Lager
drawOriginalSupports(Knoten, Staebe, Lager, meanL, nStaebe);

% 3) Federn
drawOriginalSprings(Knoten, Feder, meanL);

% 4) Querschnitte (EIinf) + Gelenke (Releases & Momentengelenke)
drawOriginalReleasesAndHinges(Knoten, Staebe, Stab, meanL, nKnoten, nStaebe);

% 5) Verteilte Stablasten
drawOriginalDistributedMemberLoads(Knoten, Staebe, StabLast_vert, meanL, meanSLv);

% 6) Konzentrierte Stablasten
drawOriginalConcentratedMemberLoads(Knoten, Staebe, StabLast_konz, meanL, meanSLk);

% 7) Knotenlasten
drawOriginalNodalLoads(Knoten, KnotenLast, meanL, meanKL, nKL);

out = [];   % optional, just to have a defined output

end