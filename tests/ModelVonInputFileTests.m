function [model] = ModelVonInputFileTests(inputFile)
%dieses File ruft die ursprünglichen Testfiles auf
%falls dieses verwendet werden soll -> in MatrizenStatik auf Zeile 9 diese Funktion aufrufen
%just a small change
    switch inputFile
        case 1
            model = InputFile1();
        case 2
            model = InputFile2();
        case 3
            model = InputFile3(); %Kolloqium 6 Aufgabe 2
        case 4
            model = InputFile4(); %Kolloqium 6 Aufgabe 1
        case 5
            model = InputFile5(); 
        case 6
            model = InputFile6(); %Hausübung 6 Aufgabe 1
        case 7
            model = InputFile7(); %Hausübung 7 Aufgabe 2
        case 8
            model = InputFile8(); %Hausübung 4 Aufgabe 1
        case 9
            model = InputFile9(); %Hausübung 5 Aufgabe 2
        case 10
            model = InputFile10(); %Kolloqium 4 Aufgabe 2
        case 11
            model = InputFile11();
        case 12
            model = InputFile12(); %Hausübung 2 Aufgabe 2
        case 13
            model = InputFile13(); %Hausübung 1 Aufgabe 3c
        case 14
            model = InputFile14();
        case 15
            model = InputFile15();
        case 16
            model = InputFile16(); %MATLAB-Übung 2
        case 30
            model = InputFile30();
        case 31
            model = InputFile31();
        case 32
            model = InputFile32(); %Kolloqium 7.2 Aufgabe 1
        case 33
            model = InputFile33(); %Beispiel Vorlesung
        case 34
            model = InputFile34(); %Hausübung 5 Aufgabe 4
        case 35
            model = InputFile35();
        case 36
            model = InputFile36();
        case 100
            InputFileT;
        case 101
            InputFileT1;
        case 102
            InputFileT2; %Prüfung FS22 Aufgabe Einflusslinie
        case 103
            InputFileT3;
        otherwise
            disp('InputFile kann nicht gefunden werden.')
            return         
    end

    if inputFile >= 100
        model = in;
    end
    
end

