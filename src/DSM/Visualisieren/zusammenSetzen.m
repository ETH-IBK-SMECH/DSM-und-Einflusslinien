function out = zusammenSetzen(analyseModel)

gew_output = analyseModel.gew_output; % 1:Schnittkräfte, 2:Einflusslinie


   if gew_output == 1 || gew_output == 3
       out = schnittkraefte(analyseModel);
   elseif gew_output == 2
       out = verformungslinie(analyseModel);
   end


end

