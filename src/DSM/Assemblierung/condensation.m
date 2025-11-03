function [K_out, f_out, meta] = condensation(K, f, keepMask, varargin)
%KONDENSATION Dienstprogramm zur statischen Kondensation (eine Funktion für alle Fälle).
%
% [K_out, f_out, meta] = condensation(K, f, keepMask, 'preserve_size', true/false, 'known_ui', ui)
%
% Eingaben
% K : (n x n) Steifigkeitsmatrix
% f : (n x 1) Lastvektor (kann [] sein, falls nicht benötigt)
% keepMask : logischer Vektor (1 x n) oder Indexvektor der zu BEHALTENDEN Freiheitsgrade (die „äußere" Menge e)
%
% Name-Wert-Paare
% 'preserve_size' (Standardwert: true)
% true → gibt eine n x n-Matrix zurück, in der nur der e×e-Block gefüllt ist (andere Elemente = 0)
% false → gibt die reduzierte Matrix K_ee zurück (Größe ne x ne)
% 'known_ui' ([] standardmäßig)
% Falls angegeben, wird nur die einfache Reduktion der rechten Seite durchgeführt:
% f_e - K_ei * u_i, und K_out = K_ee.
% Wird verwendet für System-Kondensation, wenn ui vorgegeben ist.
%
% Ausgaben
% K_out : kondensierte Steifigkeitsmatrix (Form abhängig von preserve_size)
% f_out : kondensierter Lastvektor (passende Form)
% meta : Struktur mit eIdx, iIdx, ne, n (praktisch für Mapping, Debugging, Tests)

% optionen einlesen
opts.preserve_size = true;
opts.known_ui = [];
if mod(numel(varargin), 2) ~= 0
    error('Kondensation:NameValuePairs', 'Expected name/value pairs.');
end
for k = 1:2:numel(varargin)
    opts.(varargin{k}) = varargin{k+1};
end

% e/i gruppen aufbauen
n = size(K, 1);
if islogical(keepMask), e = find(keepMask);
else, e = keepMask(:)';
end
i  = setdiff(1:n, e);
ne = numel(e);

% if doing RHS reduction, ui must match length(i)
if ~isempty(opts.known_ui) && numel(opts.known_ui) ~= numel(i)
    error('Kondensation:known_ui_size', 'numel(known_ui)=%d must match numel(i)=%d.', numel(opts.known_ui), numel(i));
end

% outputs allozieren
if opts.preserve_size
    K_out = zeros(n, n, 'like', K);
    f_out = [];
    if ~isempty(f), f_out = zeros(n, 1, 'like', f); end
else
    K_out = zeros(ne, ne, 'like', K);
    f_out = [];
    if ~isempty(f), f_out = zeros(ne, 1, 'like', f); end
end

% Berechnungen
Kee = K(e, e);
if isempty(opts.known_ui) % u_i eliminieren
    if isempty(i)
        Kred = Kee;
        if ~isempty(f), fred = f(e);
        end
    else
        Kei = K(e, i);
        Kii = K(i, i);
        Kie = K(i, e);
        Kred = Kee - Kei * (Kii \ Kie);
        if ~isempty(f), fred = f(e) - Kei * (Kii \ f(i)); end
    end
else % falls u_i bekannt
    Kred = Kee;
    if ~isempty(f)
        fred = f(e) - K(e, i) * opts.known_ui;
    end
end

% korrekte grösse zuordnen
if opts.preserve_size
    K_out(e, e) = Kred;
    if ~isempty(f), f_out(e) = fred; end
else
    K_out = Kred;
    if ~isempty(f), f_out = fred; end
end

if nargout > 2
    meta = struct('eIdx', e, 'iIdx', i, 'ne', ne, 'n', n);
end
end
