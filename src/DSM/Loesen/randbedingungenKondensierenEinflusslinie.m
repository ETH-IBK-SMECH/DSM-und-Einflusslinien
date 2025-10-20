function kond = randbedingungenKondensierenEinflusslinie( ...
        K_sys, F_sys, SPC, DOF, nDOF, nkd, Einflusslinie)

if nDOF < 2*nkd
    error('Einflusslinie: not enough DOFs for [I -I] tail (%d < %d).', nDOF, 2*nkd);
end
A = sparse(nkd, nDOF);
cols1 = (nDOF - 2*nkd + 1) : (nDOF - nkd);
cols2 = (nDOF - nkd + 1)   :  nDOF;
for k = 1:nkd, A(k, cols1(k)) = 1;  A(k, cols2(k)) = -1; end

comp = 1;
if isfield(Einflusslinie,'TypEL') && isfinite(Einflusslinie.TypEL) && Einflusslinie.TypEL>=1 && Einflusslinie.TypEL<=nkd
    comp = Einflusslinie.TypEL;
end
F2 = zeros(nkd,1); F2(comp) = -1; if comp == 2, F2(comp) = 1; end

K_aug = [K_sys, A'; A, sparse(nkd, nkd)];
F_aug = [F_sys; F2];

nExt   = nDOF + nkd;
isKnown = false(1, nExt);
U_s     = zeros(nExt,1);
for i = 1:numel(SPC)
    localIdx = (SPC(i).node-1)*nkd + SPC(i).dir;
    g = safeDOF(localIdx, DOF);
    if g ~= 0
        isKnown(g) = true; U_s(g) = U_s(g) + SPC(i).val;
    end
end

isFree = ~isKnown;
fIdx   = find(isFree); sIdx = find(isKnown);
K_ff   = K_aug(fIdx, fIdx);
F_f    = F_aug(fIdx) - K_aug(fIdx, sIdx)*U_s(sIdx);

kond = struct('K_sys_ff',K_ff,'F_sys_f_kond',F_f, ...
              's',isKnown,'f',isFree,'DOF',fIdx, ...
              'known',struct('mask',isKnown,'U_s',U_s(isKnown)), ...
              'nLM',nkd);
end
