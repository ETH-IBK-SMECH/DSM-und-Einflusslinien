function [out] = drawOriginalFig(ax, Model)

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

nKL = numel(KnotenLast);
meanL = mean([Stab.L]);
xAll = [Knoten.xPos];
yAll = [Knoten.yPos];
Lsys = hypot(max(xAll)-min(xAll), max(yAll)-min(yAll));
if ~isfinite(Lsys) || Lsys <= 0
    Lsys = meanL;
end

%L_arrow  = 0.15 * Lsys;   % base arrow length in plot units
%R_moment = 0.08 * Lsys;   % base moment arrow radius in plot units
L_arrow = 0.3 * meanL;
R_moment = 0.1 * meanL;

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

% ==== Ab hier nur noch Zeichnen: aufteilen in drawOriginalXY-Funktionen ====

hold(ax, 'on');

hgStab = hggroup(ax);
hgStabNummer = hggroup(ax);
% 1) Stäbe (mit L, c, s, R) zeichnen
Staebe = drawOriginalBeams(ax, Knoten, Staebe, hgStab, hgStabNummer);

% 2) Lager
drawOriginalSupports(ax, Knoten, Staebe, Lager, meanL, nStaebe);

% 3) Federn
drawOriginalSprings(ax, Knoten, Feder, meanL);

% 4) Querschnitte (EIinf) + Gelenke (Releases & Momentengelenke)
drawOriginalReleasesAndHinges(ax, Knoten, Staebe, Stab, meanL, nKnoten, nStaebe, hgStab);

% 5) Verteilte Stablasten
drawOriginalDistributedMemberLoads(ax, Knoten, Staebe, StabLast_vert, meanL, 0.75*L_arrow);

% 6) Konzentrierte Stablasten
drawOriginalConcentratedMemberLoads(ax, Knoten, Staebe, StabLast_konz, meanL, L_arrow, R_moment);

% 7) Knotenlasten
drawOriginalNodalLoads(ax, Knoten, KnotenLast, meanL, nKL, L_arrow, R_moment);

% Legende um alle Stabelemente zu gruppieren
hLegStaebe = plot(ax, NaN, NaN, 'w', 'LineWidth', 5, ...
    'DisplayName', 'Staebe');
hLegStaebe.UserData = hgStab;
hLegStaebe.HitTest  = 'off';

hLegStabNummer = plot(ax, NaN, NaN, ...
    '>', ...                    % marker only
    'Color', [1.0, 0.5, 0.0], ...
    'MarkerFaceColor', [1.0, 0.5, 0.0], ...
    'MarkerSize', 6, ...
    'LineStyle', 'none', ...     % no line
    'DisplayName', 'Stabnummer');
    hLegStabNummer.UserData = hgStabNummer;                       % link legend item -> group
    hLegStabNummer.HitTest = 'off';                     % legend click still

hold(ax, 'off');

out = [];   % optional, just to have a defined output

end