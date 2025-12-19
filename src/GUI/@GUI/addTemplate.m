% helper function for creating table templates
function addTemplate(app, name, format, emptyRow)
app.ColumnTemplates.(name).format = format;
app.ColumnTemplates.(name).emptyRow = emptyRow;
end
