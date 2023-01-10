function [Model, status, Meldung] = MatrizenStatik(inputFile)
%% Beschreibung dieser Funktion
% dies ist das main-file, welches darstellt in welcher Reihenfolge der Input behandelt wird bis zum Output

addpath('Input','DSM','DSM/Funktionen','Output','Zeichnen');

%% Input aquirieren
   % für den Moment erstellen wir händisch die entsprechenden Inputfiles. Später kommen diese direkt aus dem GUI.
   [Model.Input] = ModelVonInputFile(inputFile);
            
%% Input überprüfen und gegebenfalls bereinigen
   [erfolgreich, status, ErrorMeldung] = istGueltigerInput(Model.Input); %behandle Error (d.h. User muss seine Eingabe anpassen)
   if ~erfolgreich 
     status = -1; 
     Meldung = ErrorMeldung; 
     return; 
   end

%% Input umwandeln (Model.Input._ --> Model.Analyse._)
   [Model.Analyse] = inputUmwandeln(Model.Input);

%% Model umwandeln für Einflusslinie
    if Model.Analyse.gew_output == 2
        [Model.Analyse] = ModelFuerEinflusslinie([Model.Analyse]);
    end

%% System Lösen (Model.Analyse._ lösen)
   [Model.Analyse] = DirectStiffnessMethod([Model.Analyse]);

%% Output darstellen
   [Model.Output] = ZusammenSetzen([Model.Analyse]);
   OutputDarstellung(Model);

end

