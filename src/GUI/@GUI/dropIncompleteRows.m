function T = dropIncompleteRows(app, T, requiredVars)
% Removes rows from table T that contain NaN, empty, or "– wählen –"
% in any of the requiredVars columns.
if ~istable(T) || isempty(T)
    return;
end
keep = true(height(T), 1);

for k = 1:numel(requiredVars)
    v = string(requiredVars{k});
    if ~ismember(v, string(T.Properties.VariableNames))
        continue;
    end

    col = T.(v);

    if isnumeric(col) || islogical(col)
        keep = keep & ~isnan(col);

    elseif isstring(col)
        keep = keep & col ~= "– wählen –" & strlength(col) > 0;

    elseif iscell(col)
        s = string(col);
        keep = keep & s ~= "– wählen –" & strlength(s) > 0;
    end
end

T = T(keep, :);
end
