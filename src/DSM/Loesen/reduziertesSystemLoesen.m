function u_free = reduziertesSystemLoesen(K_red, F_red)
% Numerische Lösung mit einfacher Konditionsprüfung
r = sprank(K_red);
n = size(K_red, 1);
if r < n
    warning('Mechanismus erkannt: System hat %d freie DOF, aber nur Rang %d.', n, r);
end
rc_est = condest(K_red);
rce = 1 / rc_est;
if ~isfinite(rce) || rce < 1e-12
    warning('K_red ist schlecht konditioniert (rcond~%g). Prüfe Lager/Gelenke.', rce);
end
u_free = K_red \ F_red;
if any(~isfinite(u_free))
    error('Lösung enthält NaN/Inf. System wahrscheinlich singulär. Prüfe Lager/Gelenke');
end
end
