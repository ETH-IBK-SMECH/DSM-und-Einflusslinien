function codes = mapDropdown(app, colValues, labels, offset)
% colValues : column from a table (cell/char/string)
% labels    : cellstr with dropdown labels (in the order of codes)
% offset    : optional; add this to the index (e.g. -1 for hinges with 0 = "kein Gelenk")

if nargin < 4
    offset = 0;
end

s = string(colValues); % normalize to string array
s = strtrim(s); % incase accidental space is added

% Map label -> index
[~, idx] = ismember(s, string(labels));

codes = idx + offset;
end
