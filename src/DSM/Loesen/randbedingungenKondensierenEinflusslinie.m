function kond = randbedingungenKondensierenEinflusslinie( ...
        K_sys, F_sys, SPC, DOF, nDOF, nkd, Einflusslinie, model)
% Minimal legacy IL path: augment with [I -I] on the last 2*nkd DOFs and nkd LM.
% Matches the old behavior used in your pre-refactor code.

% --- 1) Build A = [0 ... 0  I  -I] on last 2*nkd columns (legacy)
if nDOF < 2*nkd
    error('Einflusslinie: not enough DOFs for legacy [I -I] tail (%d < %d).', nDOF, 2*nkd);
end
A = sparse(nkd, nDOF);
cols1 = (nDOF - 2*nkd + 1) : (nDOF - nkd);
cols2 = (nDOF - nkd + 1)   :  nDOF;
for k = 1:nkd
    A(k, cols1(k)) =  1;
    A(k, cols2(k)) = -1;
end

% --- 2) RHS block F2 with legacy sign rule
comp = 1; % default component
if isfield(Einflusslinie,'TypEL') && isfinite(Einflusslinie.TypEL) && ...
   Einflusslinie.TypEL>=1 && Einflusslinie.TypEL<=nkd
    comp = Einflusslinie.TypEL;
end
F2 = zeros(nkd,1);
F2(comp) = -1;
if comp == 2, F2(comp) = 1; end   % legacy special case

% --- 3) Augment K and F with LM
K_aug = [K_sys, A'; A, sparse(nkd, nkd)];
F_aug = [F_sys; F2];

% --- 4) Known/Free masks incl. LM (LM are free)
nExt = nDOF + nkd;
isKnown = false(1, nExt);
U_s     = zeros(nExt,1);

% Collect SPC into known mask (only physical DOFs 1..nDOF)
for i = 1:numel(SPC)
    g = SPC(i).DOF;
    if g>=1 && g<=nDOF
        isKnown(g) = true;
        U_s(g)     = U_s(g) + SPC(i).val;
    end
end

% --- 5) Condense SPC (Dirichlet) on the augmented system
isFree = ~isKnown;                 % LM are free by construction
fIdx   = find(isFree);
sIdx   = find(isKnown);

K_ff   = K_aug(fIdx, fIdx);
K_fs   = K_aug(fIdx, sIdx);
F_f    = F_aug(fIdx) - K_fs * U_s(sIdx);

% --- 6) Return in legacy-compatible structure
kond = struct();
kond.K_sys_ff      = K_ff;
kond.F_sys_f_kond  = F_f;
kond.s             = isKnown;      % full (phys + LM)
kond.f             = isFree;       % full (phys + LM)
kond.DOF           = fIdx;         % indices of free unknowns in augmented system
kond.known         = struct('mask', isKnown, 'U_s', U_s(isKnown));
kond.nLM           = nkd;          % number of LMs appended (so you can truncate later)
end
