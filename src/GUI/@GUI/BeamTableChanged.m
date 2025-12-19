function BeamTableChanged(app)
n = size(app.Table_Beam.Data, 1);
% only string lists allowed in pop-up menus and min 1 item
items = [{'– wählen –'}, cellstr(string(1:n))];
app.Dropdown_BeamNumbers = items;
% update all the respective columns
app.Table_PointLoad.ColumnFormat{1} = app.Dropdown_BeamNumbers;
app.resetInvalidDropdownEntries(app.Table_PointLoad, 1, items);
app.Table_DistrLoad.ColumnFormat{1} = app.Dropdown_BeamNumbers;
app.resetInvalidDropdownEntries(app.Table_DistrLoad, 1, items);
app.Table_InfluenceLine_1.ColumnFormat{1} = app.Dropdown_BeamNumbers;
app.resetInvalidDropdownEntries(app.Table_InfluenceLine_1, 1, items);
end
