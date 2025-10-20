function  [Knoten, Stab, Teilsystem, Feder, KnotenLast, StabLast, SPC, Info, gew_output, Einflusslinie] = extractFields(analysisModel)
   Knoten     = analysisModel.Knoten;
   Stab       = analysisModel.Stab;
   Teilsystem = analysisModel.Teilsystem;
   Feder      = analysisModel.Feder;
   KnotenLast = analysisModel.KnotenLast;
   StabLast   = analysisModel.StabLast;
   SPC        = analysisModel.SPC;
   
   Info       = analysisModel.Info;
   gew_output = analysisModel.gew_output;
   Einflusslinie = analysisModel.Einflusslinie;
   %...
end