function clearPanelTables(app, panelKey)
switch panelKey
    case "Material"
        if ~isempty(app.Table_Material.Data)
            app.clearTable("MaterialTable");
            MaterialTableChanged(app);
        end
    case "Section"
        if ~isempty(app.Table_Section.Data)
            app.clearTable("SectionTable");
            SectionTableChanged(app);
        end
    case "Beam"
        if ~isempty(app.Table_Node.Data)
            app.clearTable("NodeTable");
            NodeTableChanged(app);
        end
        if ~isempty(app.Table_Beam.Data)
            app.clearTable("BeamTable");
            BeamTableChanged(app);
        end
        if ~isempty(app.Table_Support.Data)
            app.clearTable("SupportTable");
        end
        if ~isempty(app.Table_Spring.Data)
            app.clearTable("SpringTable");
        end
    case "Actions"
        if ~isempty(app.Table_NodalLoad.Data)
            app.clearTable("NodalLoadTable");
        end
        if ~isempty(app.Table_PointLoad.Data)
            app.clearTable("PointLoadTable");
        end
        if ~isempty(app.Table_DistrLoad.Data)
            app.clearTable("DistrLoadTable");
        end
        if ~isempty(app.Table_ForcedDispl.Data)
            app.clearTable("ForcedDisplTable");
        end
end
app.rowNumber = [];
end
