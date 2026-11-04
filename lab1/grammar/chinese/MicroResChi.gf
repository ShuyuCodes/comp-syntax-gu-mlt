resource MicroResChi = open Prelude in {

param
  Number = Sg | Pl ;
  Case = Nom | Acc ;


  Agreement = Agr Number ; ---s Person to be added

oper
  Noun : Type = {s : Str};

  mkNoun : Str -> Noun = \word -> {
    s = word
    } ;

  Adjective : Type = {s : Str} ;

  Verb : Type = {s : Str} ;

  mkVerb : Str -> Verb = \word -> {
    s = word
    } ;

  -- two-place verb with "case" as preposition; for transitive verbs, c=[]
  Verb2 : Type = Verb ** {c : Str} ;

  be_Verb : Verb = mkVerb "是" ; 

}
