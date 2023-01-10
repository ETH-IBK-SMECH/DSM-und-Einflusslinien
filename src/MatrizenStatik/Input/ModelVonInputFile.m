function [model] = ModelVonInputFile(inputFile)

    switch inputFile
        case 0
            InputFile;
        case 1
            InputFileTest1; % Bsp. Schnittkräfte: Matlab-Übung 2
        case 2
            InputFileTest2; % Bsp. Einflusslinie: Prüfung FS22 Aufgabe Einflusslinie
        case 3
            InputFileTest3; % Bsp. Auflagerreaktionen: System Prüfung FS22 Aufgabe 2 Teil II
        case 4
            InputFileTest4; % Bsp. Schnittkräfte: Hausübung 6 Augabe 1
        case 5
            InputFileTest5; % Bsp. Einflusslinie: Kolloqium 7.2 Aufgabe 1
        otherwise
            disp('InputFile kann nicht gefunden werden.')     
    end

    model = in;
    
end

