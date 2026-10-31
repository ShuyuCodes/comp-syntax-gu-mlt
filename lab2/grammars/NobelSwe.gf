concrete NobelSwe of Nobel = LabelsSwe ** open
  SyntaxSwe,
  ParadigmsSwe,
  SymbolicSwe,
  IrregSwe
in {

lincat
  Sentence = S ;
  Name = NP ;
  Date = Adv ;

lin
  BornSentence name country date =
    mkS pastTense (mkCl name (mkVP (mkVP born_VP (inAdv country)) date)) ;

  AwardSentence name award date =
    mkS pastTense (mkCl name (mkVP (mkVP get_V2 award) date)) ;

  DiedSentence name date =
    mkS pastTense (mkCl name (mkVP die_VP date)) ;

  StringName s = symb s ;

  YearDate i = inAdv <symb i : NP> ;

  he_Name = he_NP ;
  she_Name = she_NP ;
  they_Name = they_NP ;

oper
  inAdv : NP -> Adv = \np -> SyntaxSwe.mkAdv in_Prep np ;

  born_VP = mkVP (mkA "född") ;   -- use appropriate Swedish word
  die_VP = mkVP (mkV "dog") ;     -- optional, if needed

  get_V  = mkV "fick" ;            -- define the base verb

  get_V2 = mkV2 get_V ;

}
