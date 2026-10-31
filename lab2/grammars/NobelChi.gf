concrete NobelChi of Nobel = LabelsChi ** open
  SyntaxChi,
  ParadigmsChi,
  SymbolicChi
  -- IrregChi -- Chinese does not require an `Irreg` module,
              -- since verbs are not inflected for tense or agreement.
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

  -- FemaleName s = symb s ; -- use if your language needs gender agreement
  -- MaleName s = symb s ; -- use if your language needs gender agreement
  StringName s = symb s ;

  YearDate i = inAdv <symb i : NP> ;

  he_Name = he_NP ;
  she_Name = she_NP ;
  they_Name = they_NP ;

oper
  -- inAdv : NP -> Adv = \np -> SyntaxChi.mkAdv in_Prep np ;
  inAdv : NP -> Adv = \np -> SyntaxChi.mkAdv (mkPrep "在") np ;

  born_VP = mkVP (mkV "出生") ;   -- or "诞生"
  die_VP = mkVP (mkV "去世") ;    -- or "死亡"
  get_V2 = mkV2 (mkV "荣获") ;   -- for 奖项

}
