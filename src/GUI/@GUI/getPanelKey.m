function key = getPanelKey(app, panelHandle)
% Maps a panel handle to the corresponding key string
key = "";

if isempty(panelHandle) || ~isvalid(panelHandle)
    return;
end

if panelHandle == app.Panel_Material
    key = "Material";
elseif panelHandle == app.Panel_Section
    key = "Section";
elseif panelHandle == app.Panel_Beam
    key = "Beam";
elseif panelHandle == app.Panel_Actions
    key = "Actions";
elseif panelHandle == app.Panel_Result
    key = "Result";
end
end
