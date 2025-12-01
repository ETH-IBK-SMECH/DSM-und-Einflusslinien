function u_free = reduziertesSystemLoesen(K_red, F_red)
% Numerische Lösung mit einfacher Konditionsprüfung

[~, p_chol] = chol(K_red);
if p_chol ~= 0
    warning('Mechanismus oder unzureichende Lagerung vermutet.');
end
rc_est = condest(K_red);
rce = 1 / rc_est;
if ~isfinite(rce) || rce < 1e-10
    warning('K_red ist schlecht konditioniert (rcond~%g).', rce);
end
u_free = K_red \ F_red;
if any(~isfinite(u_free))
    error('Lösung enthält NaN/Inf. System wahrscheinlich singulär. Prüfe Lager/Gelenke');
end
end
