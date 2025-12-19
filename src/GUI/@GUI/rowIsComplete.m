function ok = rowIsComplete(app, T, rowIdx, requiredVars)
% T            : table
% rowIdx       : row index to check
% requiredVars : cellstr/string array of required column names

ok = true;

if rowIdx < 1 || rowIdx > height(T)
    ok = false;
    return;
end

for k = 1:numel(requiredVars)
    v = string(requiredVars{k});
    if ~ismember(v, string(T.Properties.VariableNames))
        ok = false;
        return;
    end

    val = T.(v)(rowIdx);

    % Check for "empty" / default
    if isnumeric(val) || islogical(val)
        if isnan(val)
            ok = false;
            return;
        end
    elseif isstring(val)
        if strlength(val) == 0 || val == "– wählen –"
            ok = false;
            return;
        end
    elseif iscell(val)
        c = val{1};
        if isempty(c)
            ok = false;
            return;
        end
        if isstring(c)
            if strlength(c) == 0 || c == "– wählen –"
                ok = false;
                return;
            end
        elseif ischar(c)
            if isempty(strtrim(c)) || strcmp(c, "– wählen –")
                ok = false;
                return;
            end
        end
    else
        % any weird type -> treat empty / missing as incomplete
        if isempty(val)
            ok = false;
            return;
        end
    end
end
end
