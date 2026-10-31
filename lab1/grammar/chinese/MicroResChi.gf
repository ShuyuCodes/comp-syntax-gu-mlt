resource MicroResChi = open Prelude in {

param
  Number = Sg | Pl ;
  Case = Nom | Acc ;

  Agreement = Agr Number ; ---s Person to be added

oper
  Noun : Type = {s : Number => Str} ;

  mkNoun : Str -> Str -> Noun = \sg,pl -> {
    s = table {Sg => sg ; Pl => pl}
    } ;

  Adjective : Type = {s : Str} ;

  Verb : Type = {s : Str} ;

  Verb2 : Type = Verb ** {c : Str} ;

  be_Verb : Verb = {s = "是"} ;

}
