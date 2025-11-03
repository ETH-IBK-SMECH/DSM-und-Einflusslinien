function kond = randbedingungenKondensierenEinflusslinie( ...
    K_sys, F_sys, SPC, DOF, nkd, Einflusslinie)
% Einflusslinie (TypEL 1..3) via Lagrange-Multiplikatoren.

n = size(K_sys, 1);
cutNode1 = Einflusslinie.cutNodes(1);
cutNode2 = Einflusslinie.cutNodes(2);
keep = logical(Einflusslinie.keepMask(:)); % 1×nkd
comp = Einflusslinie.TypEL;

% --- Lokale → globale DOF-IDs der beiden Schnittknoten ---
loc1 = (cutNode1 - 1) * nkd + (1:nkd);
loc2 = (cutNode2 - 1) * nkd + (1:nkd);
g1 = DOF(loc1);
g1 = g1(:); % 0 = inaktiv
g2 = DOF(loc2);
g2 = g2(:);

% --- Nur Komponenten behalten, die auf BEIDEN Seiten existieren + keepMask ---
keep = keep & (g1 ~= 0) & (g2 ~= 0);
alive = find(keep); % Indizes in {1..nkd}, die aktiv sind
m = numel(alive); % Anzahl LM-Gleichungen
if m == 0
    error('Einflusslinie: am Schnitt sind keine aktiven DOF-Paare vorhanden.');
end
g1f = g1(keep);
g2f = g2(keep);

% --- Einheitsaktion in der zum gewünschten Typ gehörenden LM-Reihe ---
p = find(alive == comp, 1, 'first');
F2 = zeros(m, 1);
if ~isempty(p)
    % Vorzeichenkonvention: V positiv, sonst negativ
    F2(p) = (comp == 2) * (+1) + (comp ~= 2) * (-1);
end

% --- Kopplungsmatrix A  ---
A = sparse(m, n);
A(sub2ind([m, n], (1:m).', g1f)) = 1;
A(sub2ind([m, n], (1:m).', g2f)) = -1;

% --- Augmentiertes System aufstellen ---
K_aug = [K_sys, A'; A, sparse(m, m)];
F_aug = [F_sys; F2];

% --- Randbedingungen nur auf physischen DOFs ---
isKnown_aug = false(1, n+m);
U_aug = zeros(n+m, 1);
for i = 1:numel(SPC)
    localIdx = (SPC(i).node - 1) * nkd + SPC(i).dir;
    g = DOF(localIdx);
    if g ~= 0
        isKnown_aug(g) = true;
        U_aug(g) = U_aug(g) + SPC(i).val;
    end
end

% --- Reduziertes System bilden ---
fIdx = find(~isKnown_aug);
sIdx = find(isKnown_aug);

Kff = K_aug(fIdx, fIdx);
Kfs = K_aug(fIdx, sIdx);
Uf = U_aug(sIdx);
Ff = F_aug(fIdx);

Fr = Ff - Kfs * Uf;

% --- Rückgabe für Einsammeln / Weiterverarbeitung ---
phys_knownMask = isKnown_aug(1:n);
kond = struct( ...
    'K_sys_ff', Kff, ...
    'F_sys_f_kond', Fr, ...
    'nLM', m, ...
    'phys_freeMask', ~phys_knownMask, ...
    'known_U_vector', U_aug(phys_knownMask) ...
    );
end
