function SectionTableChanged(app)
items = app.Table_Section.Data(:, 1).';
% stable when no name
items = items(items ~= "");
% Dropdown needs at least 2 items
items = [{'– wählen –'}, items];
app.Dropdown_SectionNames = items;
% update all the respective columns
app.Table_Beam.ColumnFormat{3} = app.Dropdown_SectionNames;
app.resetInvalidDropdownEntries(app.Table_Beam, 3, items);
end
