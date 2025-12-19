% maybe simplify into one function?
function MaterialTableChanged(app)
items = app.Table_Material.Data(:, 1).';
% stable when no name
items = items(items ~= "");
% Dropdown needs at least 2 items
items = [{'– wählen –'}, items];
app.Dropdown_MaterialNames = items;
% update all the respective columns
app.Table_Section.ColumnFormat{2} = app.Dropdown_MaterialNames;
app.resetInvalidDropdownEntries(app.Table_Section, 2, items);
end
