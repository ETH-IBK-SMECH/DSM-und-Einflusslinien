function NodeTableChanged(app)
n = size(app.Table_Node.Data, 1);
% only string lists allowed in pop-up menus and min 1 item
items = [{'– wählen –'}, cellstr(string(1:n))];
app.Dropdown_NodeNumbers = items;
% update all the respective columns
app.Table_Beam.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_Beam, 1, items);
app.Table_Beam.ColumnFormat{2} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_Beam, 2, items);
app.Table_Support.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_Support, 1, items);
app.Table_Spring.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_Spring, 1, items);
app.Table_NodalLoad.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_NodalLoad, 1, items);
app.Table_ForcedDispl.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_ForcedDispl, 1, items);
app.Table_InfluenceLine_2.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_InfluenceLine_2, 1, items);
app.Table_StatCond.ColumnFormat{1} = app.Dropdown_NodeNumbers;
app.resetInvalidDropdownEntries(app.Table_StatCond, 1, items);
end
