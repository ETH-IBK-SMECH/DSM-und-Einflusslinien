function Model = buildPreviewModel(app, in)
% Build a lightweight Model struct from GUI input "in"
% so that drawOriginalFig(Model) can be reused for live preview.

Model = struct();
Model.Input = struct();
Model.Analyse = struct();

% --- Input: directly from GUI tables ---

% Nodes (Knoten) – keep as table; drawOriginalFig already handles table->struct
if istable(in.Knoten)
    Model.Input.Knoten = in.Knoten;
else
    Model.Input.Knoten = struct2table(in.Knoten);
end

% Beams (Staebe) – GUI stores table with StartKnoten/EndKnoten etc.
if isfield(in, "Staebe") && istable(in.Staebe)
    Model.Input.Staebe = in.Staebe;
else
    Model.Input.Staebe = table();
end

% Supports (Lager)
if isfield(in, "Lager") && istable(in.Lager)
    Model.Input.Lager = in.Lager;
else
    Model.Input.Lager = table();
end

% --- Analyse.Feder from GUI "Feder" table ---

Feder = struct('node', {}, 'dir', {}, 'val', {});
if isfield(in, "Feder") && istable(in.Feder) && ~isempty(in.Feder)
    Ft = in.Feder;
    s = table2struct(Ft);
    Feder(1:numel(s)) = struct('node', [], 'dir', [], 'val', []);
    for i = 1:numel(s)
        Feder(i).node = s(i).Knoten;
        Feder(i).dir = s(i).Feder;
        Feder(i).val = s(i).Betrag;
    end
end
Model.Analyse.Feder = Feder;

% --- Analyse.KnotenLast from GUI "KnotenLasten" table ---

KnotenLast = struct('node', {}, 'dir', {}, 'val', {});
if isfield(in, "KnotenLasten") && istable(in.KnotenLasten) && ~isempty(in.KnotenLasten)
    KLt = in.KnotenLasten;
    s = table2struct(KLt);
    KnotenLast(1:numel(s)) = struct('node', [], 'dir', [], 'val', []);
    for i = 1:numel(s)
        KnotenLast(i).node = s(i).Knoten;
        KnotenLast(i).dir = s(i).Richtung;
        KnotenLast(i).val = s(i).Wert;
    end
end
Model.Analyse.KnotenLast = KnotenLast;

% --- Analyse.StabLast from GUI "StabLasten_konzentriert" + "StabLasten_verteilt" ---

StabLast = struct('stab', {}, 'dir', {}, 'val', {}, ...
    'sDist', {}, 'eDist', {}, 'typ', {});

% Point loads on beams
if isfield(in, "StabLasten_konzentriert") && istable(in.StabLasten_konzentriert) ...
        && ~isempty(in.StabLasten_konzentriert)

    Pt = in.StabLasten_konzentriert;
    s = table2struct(Pt);
    for i = 1:numel(s)
        idx = numel(StabLast) + 1;
        StabLast(idx).stab = s(i).Stab;
        StabLast(idx).dir = s(i).Richtung;
        StabLast(idx).val = s(i).Wert;
        StabLast(idx).sDist = s(i).StartPosition;
        StabLast(idx).eDist = []; % empty = concentrated
        StabLast(idx).typ = 1;
    end
end

% Distributed loads on beams
if isfield(in, "StabLasten_verteilt") && istable(in.StabLasten_verteilt) ...
        && ~isempty(in.StabLasten_verteilt)

    Dt = in.StabLasten_verteilt;
    s = table2struct(Dt);
    for i = 1:numel(s)
        idx = numel(StabLast) + 1;
        StabLast(idx).stab = s(i).Stab;
        StabLast(idx).dir = s(i).Richtung;
        StabLast(idx).val = s(i).Wert;
        StabLast(idx).sDist = s(i).StartPosition;
        StabLast(idx).eDist = s(i).EndPosition;
        StabLast(idx).typ = 2;
    end
end

Model.Analyse.StabLast = StabLast;

% --- Analyse.Stab: minimal geometry for each beam (L, c, s, R, EIinf, releases) ---
Stab = struct('L', {}, 'c', {}, 's', {}, 'R', {}, ...
    'EIinf', {}, 'sRelease', {}, 'eRelease', {});

if istable(Model.Input.Staebe) && ~isempty(Model.Input.Staebe) ...
        && istable(Model.Input.Knoten) && ~isempty(Model.Input.Knoten)

    S = Model.Input.Staebe;
    Kt = Model.Input.Knoten;
    nStaebe = height(S);

    Stab(1:nStaebe) = struct('L', [], 'c', [], 's', [], 'R', [], ...
        'EIinf', false, 'sRelease', [], 'eRelease', []);

    for i = 1:nStaebe
        sNode = S.StartKnoten(i);
        eNode = S.EndKnoten(i);

        if any(isnan([sNode, eNode])) || sNode < 1 || eNode < 1 ...
                || sNode > height(Kt) || eNode > height(Kt)
            % degenerate / incomplete beam: dummy values
            L = 1;
            c = 1;
            s = 0;
            R = eye(3);
        else
            sX = Kt.xPos(sNode);
            eX = Kt.xPos(eNode);
            sY = Kt.yPos(sNode);
            eY = Kt.yPos(eNode);
            dx = eX - sX;
            dy = eY - sY;
            L = hypot(dx, dy);
            if L == 0
                c = 1;
                s = 0;
            else
                c = dx / L;
                s = dy / L;
            end
            R = getR(c, s); % same helper as in your original code
        end

        if ismember("GelenkStabAnfang", S.Properties.VariableNames)
            r = S.GelenkStabAnfang(i);
            if isnan(r) || r <= 0 % <=0 covers -1 and 0
                Stab(i).sRelease = [];
            else
                Stab(i).sRelease = r; % e.g. 1/2/3
            end
        end

        if ismember("GelenkStabende", S.Properties.VariableNames)
            r = S.GelenkStabende(i);
            if isnan(r) || r <= 0
                Stab(i).eRelease = [];
            else
                Stab(i).eRelease = r;
            end
        end

        % EIinf from guiToInput mapping:
        % in.Staebe.Querschnitt is a numeric section index (secIdx)
        % in.Querschnitte.biegesteif is the EIinf flag per section
        EI = false;

        if isfield(in, "Querschnitte") && istable(in.Querschnitte) && ~isempty(in.Querschnitte) && ...
                ismember("biegesteif", in.Querschnitte.Properties.VariableNames) && ...
                ismember("Name", in.Querschnitte.Properties.VariableNames) && ...
                ismember("Querschnitt", S.Properties.VariableNames)

            Qs = S.Querschnitt(i);

            secNames = string(in.Querschnitte.Name);
            QsName = string(Qs);
            QsIdx = find(secNames == QsName, 1); % [] if not found

            if ~isempty(QsIdx) && QsIdx >= 1 && QsIdx <= height(in.Querschnitte)
                EI = logical(in.Querschnitte.biegesteif(QsIdx));
            end
        end

        Stab(i).L = L;
        Stab(i).c = c;
        Stab(i).s = s;
        Stab(i).R = R;
        Stab(i).EIinf = EI;
    end
end

Model.Analyse.Stab = Stab;

end
