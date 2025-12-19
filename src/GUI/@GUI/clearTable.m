function clearTable(app, tableKey)
% Clears all rows from the given uitable
tbl = app.Tables.(tableKey);
T = tbl.Data;
tbl.Data = T([], :); % keep variable names, 0 rows
updateLiveViewer(app)
end
