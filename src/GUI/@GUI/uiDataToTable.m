% Robust function that handles most input types and turns them into
% what the solver expects
function T = uiDataToTable(~, uitab)
data = uitab.Data;

% 1) Already a table -> just return it
if istable(data)
    T = data;
    return;
end

% 2) Empty -> empty table
if isempty(data)
    T = table();
    return;
end

nCols = size(data, 2);

% 3) Build / normalise variable names
varNames = uitab.ColumnName;
if ischar(varNames) || isempty(varNames)
    % e.g. 'numbered' or empty -> auto-generate
    varNames = arrayfun(@(k) sprintf('Var%d', k), 1:nCols, ...
        'UniformOutput', false);
else
    if ~iscell(varNames)
        varNames = cellstr(varNames);
    end
    % adjust length
    if numel(varNames) < nCols
        extra = arrayfun(@(k) sprintf('Var%d', k), numel(varNames)+1:nCols, ...
            'UniformOutput', false);
        varNames = [varNames(:).', extra];
    elseif numel(varNames) > nCols
        varNames = varNames(1:nCols);
    end
end

% 4) Non-cell (numeric matrix etc.) -> wrap as table
if ~iscell(data)
    T = array2table(data, 'VariableNames', varNames);
    return;
end

% 5) Cell data: build table column by column
T = table();
for j = 1:nCols
    col = data(:, j); % cell column

    n = numel(col);
    vals = nan(n, 1);
    isNumLike = true;

    for i = 1:n
        c = col{i};

        if isempty(c)
            % empty -> NaN
            vals(i) = NaN;

        elseif isnumeric(c) || islogical(c)
            vals(i) = c;

        else
            s = strtrim(string(c));

            % Treat default dropdown / empty as "missing" but STILL numeric-like
            if s == "– wählen –" || strlength(s) == 0
                vals(i) = NaN;

            else
                % try numeric
                v = str2double(s);
                if ~isnan(v)
                    vals(i) = v;
                else
                    % truly non-numeric -> this column is not numeric
                    isNumLike = false;
                end
            end
        end

    end

    if isNumLike
        T.(varNames{j}) = vals; % numeric double column
    else
        T.(varNames{j}) = col; % keep as cell (e.g. names, Lager)
    end
end
end
