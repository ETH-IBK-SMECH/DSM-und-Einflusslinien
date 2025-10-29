function model = elementeErzeugen(model)
% Pro Stab: Geometrie, lokale Steifigkeit (inkl. Releases), Init Last-/Hilfsfelder

[Knoten, Stab, ~, ~, ~, ~, Info] = extractFields(model);
nkd = Info.nKnotenDOF;           % DOF pro Knoten
n6  = 2*nkd;                     % Element-DOF

for i = 1:Info.nStaebe
    % --- Geometrie ---
    sN = Stab(i).sNode;
    eN = Stab(i).eNode;

    sX = Knoten(sN).x;  sY = Knoten(sN).y;
    eX = Knoten(eN).x;  eY = Knoten(eN).y;

    dx = eX - sX; dy = eY - sY;
    L  = hypot(dx, dy);
    c  = dx / L; s = dy / L;
    R  = getR(c, s);                % Transformationsmatrix

    % --- Lokale Steifigkeit (voll, vor Freigaben) ---
    k_loc_v = getK(Stab(i).E, Stab(i).A, Stab(i).Iy, L); 

    % --- Releases → vorhandene DOF bestimmen & kondensieren ---
    vorhanden = true(1, n6);
    if isfield(Stab(i),'sRelease') && ~isempty(Stab(i).sRelease)
        sel = Stab(i).sRelease(:)';               % Roh-Indizes an Knoten s
        sel = sel(sel >= 1 & sel <= nkd);         % clamp
        if ~isempty(sel), vorhanden(sel) = false; end
    end
    if isfield(Stab(i),'eRelease') && ~isempty(Stab(i).eRelease)
        sel = Stab(i).eRelease(:)';               % Roh-Indizes an Knoten e
        sel = sel(sel >= 1 & sel <= nkd);
        if ~isempty(sel), vorhanden(sel + nkd) = false; end
    end

    % lokale Freigaben kondensieren (Dimension erhalten, Nullen auf gesperrten DOF)
    [k_loc, ~] = condensation(k_loc_v, [], vorhanden, 'preserve_size', true);

    % --- Felder schreiben ---
    Stab(i).L       = L;
    Stab(i).cs      = c;                 
    Stab(i).sn      = s;
    Stab(i).phi     = atan2(dy, dx);     
    Stab(i).R       = R;

    Stab(i).k_loc_v = k_loc_v;           % "voll" (vor Freigaben)
    Stab(i).k_loc   = k_loc;             % (nach Freigaben)
    Stab(i).k_glob  = rotiereLocalToGlobal_K(k_loc, R);
    Stab(i).vorhandeneDOF = vorhanden;

    % Initialisierungen für Folge-Schritte
    Stab(i).P_int  = zeros(n6,1);     % interne Elementlast 
    Stab(i).u_loc      = [];              % lokaler Verschiebungsvektor
    Stab(i).q_loc      = [];              % lokaler Endkraftvektor
    Stab(i).q_glob   = [];
end

% zurückschreiben
model.Stab = Stab;
end
