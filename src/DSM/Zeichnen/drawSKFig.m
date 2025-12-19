function [out] = drawSKFig(model)

Knoten = model.Analyse.Knoten;
KnotenKORD = table2array(struct2table(Knoten));
Stab = model.Analyse.Stab;
nStaebe = numel(Stab);
StaebeKORD = zeros(nStaebe, 2);
for i = 1:nStaebe
    StaebeKORD(i, :) = [Stab(i).sNode, Stab(i).eNode];
end

SKStab = model.Output.SKStab;

t = tiledlayout(nStaebe+1, 3);
title(t, "Schnittkraftdiagramme");

Lvec  = [Stab.L];
Lchar = median(Lvec);  
if ~isfinite(Lchar) || Lchar <= 0
    Lchar = 1;
end

% visuelle Grösse im Schnittkraftdiagramm
diagAmp = 0.3 * Lchar;

% Alle Schnittkräfte anschauen um korrekte skalierung auszuwählen
allN = []; allV = []; allM = [];
for k = 1:numel(SKStab)
    allN = [allN; SKStab(k).SK_N(:)];
    allV = [allV; SKStab(k).SK_V(:)];
    allM = [allM; SKStab(k).SK_M(:)];
end

refN95 = prctile(abs(allN), 95);
refV95 = prctile(abs(allV), 95);
refM95 = prctile(abs(allM), 95);

refNmin = prctile(abs(allN(abs(allN) > eps)), 10);
refVmin = prctile(abs(allV(abs(allV) > eps)), 10);
refMmin = prctile(abs(allM(abs(allM) > eps)), 10);

alpha = 0.3;   % 0 = use 95% only, 1 = use small values only

Nref = (1-alpha)*refN95 + alpha*refNmin;
Vref = (1-alpha)*refV95 + alpha*refVmin;
Mref = (1-alpha)*refM95 + alpha*refMmin;

% Geteilt durch null fehler umgehen
if ~isfinite(Nref) || Nref < eps, Nref = 1; end
if ~isfinite(Vref) || Vref < eps, Vref = 1; end
if ~isfinite(Mref) || Mref < eps, Mref = 1; end

% Skalierungsfaktoren
sN = -diagAmp / Nref;
sV = -diagAmp / Vref;
sM = -diagAmp / Mref;

nexttile;
for i = 1:nStaebe

    R = Stab(i).R(1:2, 1:2);

    N = [SKStab(i).KP_N; SKStab(i).SK_N * sN];

    N_rot = R' * N;

    startKnoten = Stab(i).sNode;
    startKORD = KnotenKORD(startKnoten, :)';

    N_KORD = N_rot + startKORD;

    patch(N_KORD(1, :), N_KORD(2, :), 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'b');
    patch('Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1);
end
title("N - Diagramm");
axis equal;
axis('padded')

nexttile;
for i = 1:nStaebe

    R = Stab(i).R(1:2, 1:2);

    V = [SKStab(i).KP_V; SKStab(i).SK_V * sV];

    V_rot = R' * V;

    startKnoten = Stab(i).sNode;
    startKORD = KnotenKORD(startKnoten, :)';

    V_KORD = V_rot + startKORD;

    patch(V_KORD(1, :), V_KORD(2, :), 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'b');
    patch('Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1);
end
title("V - Diagramm");
axis equal;
axis('padded')

nexttile;
for i = 1:nStaebe

    R = Stab(i).R(1:2, 1:2);

    M = [SKStab(i).KP_M; SKStab(i).SK_M * sM];

    M_rot = R' * M;

    startKnoten = Stab(i).sNode;
    startKORD = KnotenKORD(startKnoten, :)';

    M_KORD = M_rot + startKORD;

    patch(M_KORD(1, :), M_KORD(2, :), 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'b');
    patch('Faces', StaebeKORD, 'Vertices', KnotenKORD, 'LineWidth', 1);
end
title("M - Diagramm");
axis equal;
axis('padded')
assert(numel(SKStab(i).KP_M) == numel(SKStab(i).SK_M), ...
       'KP_M and SK_M length mismatch');


for i = 1:nStaebe

    x0 = [0, SKStab(i).L];
    y0 = [0, 0];


    nexttile;
    x = SKStab(i).KP_N;
    y = SKStab(i).SK_N;
    plot(x, y, 'b');
    hold on
    plot(x0, y0);
    ExtremasMarkieren(x, y);
    hold off
    title("Stab "+i+", N");
    maxN = max(SKStab(i).SK_N);
    minN = min(SKStab(i).SK_N);
    mN = max(abs(maxN), abs(minN));
    if mN < 1;
        mN = 1;
    end
    axis([0, SKStab(i).L, -mN - 0.1 * mN, mN + 0.1 * mN]);
    axis('padded')
    axis ij;

    nexttile;
    x = SKStab(i).KP_V;
    y = SKStab(i).SK_V;
    plot(x, y, 'b');
    hold on
    plot(x0, y0);
    ExtremasMarkieren(x, y);
    hold off
    title("Stab "+i+", V");
    maxV = max(SKStab(i).SK_V);
    minV = min(SKStab(i).SK_V);
    mV = max(abs(maxV), abs(minV));
    if mV < 1;
        mV = 1;
    end
    axis([0, SKStab(i).L, -mV - 0.1 * mV, mV + 0.1 * mV]);
    axis('padded')
    axis ij;

    nexttile;
    x = SKStab(i).KP_M;
    y = SKStab(i).SK_M;
    plot(x, y, 'b');
    %plot(SKStab(i).KP_M,SKStab(i).SK_VfM); %für Kontrolle von VfM
    hold on
    plot(x0, y0);
    ExtremasMarkieren(x, y);
    hold off
    title("Stab "+i+", M");
    maxM = max(SKStab(i).SK_M);
    minM = min(SKStab(i).SK_M);
    %maxM = max(SKStab(i).SK_VfM);
    %minM = min(SKStab(i).SK_VfM);
    mM = max(abs(maxM), abs(minM));
    if mM < 0.001;
        mM = 0.001;
    end
    axis([0, SKStab(i).L, -mM - 0.1 * mM, mM + 0.1 * mM]);
    axis('padded')
    axis ij;

end


end
function ExtremasMarkieren(x, y)
% Maxima, Minima und Nullpunkte mit rotem Punkt markieren

    % make column vectors
    x = x(:);
    y = y(:);

    % snap numerical noise
    tol = 1e-12 * max(1, max(abs(y)));
    y(abs(y) < tol) = 0;

    hold on

    %% --- Maxima ---
    ymax = max(y);
    imax = find(abs(y - ymax) < tol);

    plot(x(imax), y(imax), 'ro', 'MarkerFaceColor','r')

    %% --- Minima ---
    ymin = min(y);
    imin = find(abs(y - ymin) < tol);

    plot(x(imin), y(imin), 'ro', 'MarkerFaceColor','r')

    %% --- Nullpunkte
    iz = find(y(1:end-1).*y(2:end) < 0);   % sign change
    for k = iz(:).'
        % lineare Interpolation für bessere Nullpunkte
        xz = x(k) - y(k) * (x(k+1)-x(k)) / (y(k+1)-y(k));
        plot(xz, 0, 'ro', 'MarkerFaceColor','r')
    end

    hold off
end

