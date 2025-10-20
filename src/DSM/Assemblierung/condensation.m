function [K_out, f_out, meta] = condensation(K, f, keepMask, varargin)
%CONDENSATION  Static condensation utility (one function for all cases).
%
% [K_out, f_out, meta] = condensation(K, f, keepMask, 'preserve_size', true/false, 'known_ui', ui)
%
% Inputs
%   K          : (n x n) stiffness
%   f          : (n x 1) load (can be [] if not needed)
%   keepMask   : logical (1 x n) or index vector for DOFs to KEEP (the "external" set e)
%
% Name-Value
%   'preserve_size' (default true)
%       true  -> return an n x n matrix with only e×e block filled (others zero)
%       false -> return reduced K_ee (size ne x ne)
%   'known_ui' ([] by default)
%       If provided, do the simple RHS reduction:  f_e - K_ei * u_i, and K_out = K_ee (no Schur)
%       Use for system-level condensation when ui is prescribed. (Dirichlet BCs)
%
% Outputs
%   K_out      : condensed stiffness (shape depends on preserve_size)
%   f_out      : condensed force (matching shape)
%   meta       : struct with eIdx, iIdx, ne, n (handy for mapping/debugging/testing)


% parse options
opts.preserve_size = true;
opts.known_ui      = [];
if mod(numel(varargin),2)~=0
    error('condensation:NameValuePairs','Expected name/value pairs.');
end
for k = 1:2:numel(varargin)
    opts.(varargin{k}) = varargin{k+1};
end

% build e/i sets
n  = size(K,1);
if islogical(keepMask), e = find(keepMask); else, e = keepMask(:)'; end
i  = setdiff(1:n, e);
ne = numel(e);

% if doing RHS reduction, ui must match length(i)
if ~isempty(opts.known_ui) && numel(opts.known_ui) ~= numel(i)
    error('condensation:known_ui_size', 'numel(known_ui)=%d must match numel(i)=%d.', numel(opts.known_ui), numel(i));
end

% allocate outputs
if opts.preserve_size
    K_out = zeros(n, n, 'like', K);
    f_out = [];
    if ~isempty(f), f_out = zeros(n, 1, 'like', f); end
else
    K_out = zeros(ne, ne, 'like', K);
    f_out = [];
    if ~isempty(f), f_out = zeros(ne, 1, 'like', f); end
end

% calculations
Kee = K(e,e);
if isempty(opts.known_ui)          % Schur complement (eliminate unknown u_i)
    if isempty(i)
        Kred = Kee;  if ~isempty(f), fred = f(e); end
    else
        Kei = K(e,i);  Kii = K(i,i);  Kie = K(i,e);
        Kred = Kee - Kei * (Kii \ Kie);
        if ~isempty(f), fred = f(e) - Kei * (Kii \ f(i)); end
    end
else                               % RHS reduction (known u_i)
    Kred = Kee;
    if ~isempty(f)
        fred = f(e) - K(e,i) * opts.known_ui;
    end
end

% lace in requested shape
if opts.preserve_size
    K_out(e,e) = Kred;
    if ~isempty(f), f_out(e) = fred; end
else
    K_out = Kred;
    if ~isempty(f), f_out = fred; end
end

if nargout > 2
    meta = struct('eIdx', e, 'iIdx', i, 'ne', ne, 'n', n);
end
end
