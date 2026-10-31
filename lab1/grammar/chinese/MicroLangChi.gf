--# -path=.:../abstract
concrete MicroLangChi of MicroLang = open MicroResChi, Prelude in {

-----------------------------------------------------
---------------- Grammar part -----------------------
-----------------------------------------------------

  lincat
    Utt = {s : Str} ;

    S  = {s : Str} ;
    VP = {verb : Verb ; compl : Str} ; ---s special case of Mini
    Comp = {s : Str} ;
    AP = Adjective ;
    CN = Noun ;
    NP = {s : Case => Str ; a : Agreement} ;
    Pron = {s : Case => Str ; a : Agreement} ;
    Det = {s : Str ; n : Number} ;

    Prep = {prep : Str ; loc : Str} ;
    V = Verb ;
    V2 = Verb2 ;
    A = Adjective ;
    N = Noun ;
    Adv = {s : Str} ;

  lin
    UttS s = s ;
    UttNP np = {s = np.s ! Acc} ;

    PredVPS np vp = {
      s = np.s ! Nom ++ vp.verb.s ++ vp.compl
      } ;

    UseV v = {
      verb = v ;
      compl = [] ;
      } ;

    ComplV2 v2 np = {
      verb = v2 ;
      compl = v2.c ++ np.s ! Acc  -- NP object in the accusative, preposition first
      } ;

    UseComp comp = {
      verb = be_Verb ;     -- the verb is the copula "be"
      compl = comp.s
      } ;

    CompAP ap = ap ;

    AdvVP vp adv = {
      verb = {s = adv.s ++ vp.verb.s} ;
      compl = vp.compl
    } ;

    DetCN det cn = {
      s = \\c => det.s ++ cn.s ! det.n ;
      a = Agr det.n ;
      } ;

    UsePron p = p ;

    a_Det = {s = "一个" ; n = Sg} ;
    aPl_Det = {s = "一些" ; n = Pl} ;
    the_Det = {s = "这" ; n = Sg} ;
    thePl_Det = {s = "这些" ; n = Pl} ;

    UseN n = n ;

    AdjCN ap cn = {
      s = table {n => ap.s ++ cn.s ! n}
      } ;

    PositA a = a ;

    -- PrepNP prep np = {s = prep.s ++ np.s ! Acc} ;

    PrepNP prep np = {
      s = prep.prep ++ np.s ! Acc ++ prep.loc
    } ;

    in_Prep = {prep = "在" ; loc = "里"} ;
    on_Prep = {prep = "在" ; loc = "上"} ;
    with_Prep = {prep = "" ; loc = "和"} ;

    he_Pron = {
      s = table {Nom => "他" ; Acc => "他"} ;
      a = Agr Sg ;
      } ;

    she_Pron = {
      s = table {Nom => "她" ; Acc => "她"} ;
      a = Agr Sg ;
      } ;

    they_Pron = {
      s = table {Nom => "他们" ; Acc => "他们"} ;
      a = Agr Pl ;
      } ;

-----------------------------------------------------
---------------- Lexicon part -----------------------
-----------------------------------------------------
-----------------------------------------------------
---------------- Lexicon part -----------------------
-----------------------------------------------------

lin already_Adv = mkAdv "已经" ;
lin animal_N = mkN "动物" ;
lin apple_N = mkN "苹果" ;
lin baby_N = mkN "婴儿" ;
lin bad_A = mkA "坏" ;
lin beer_N = mkN "啤酒" ;
lin big_A = mkA "大" ;
lin bike_N = mkN "自行车" ;
lin bird_N = mkN "鸟" ;
lin black_A = mkA "黑" ;
lin blood_N = mkN "血" ;
lin blue_A = mkA "蓝" ;
lin boat_N = mkN "船" ;
lin book_N = mkN "书" ;
lin boy_N = mkN "男孩" ;
lin bread_N = mkN "面包" ;
lin break_V2 = mkV2 (mkV "打破") ;
lin buy_V2 = mkV2 (mkV "买") ;
lin car_N = mkN "汽车" ;
lin cat_N = mkN "猫" ;
lin child_N = mkN "孩子" "孩子们" ;
lin city_N = mkN "城市" ;
lin clean_A = mkA "干净" ;
lin clever_A = mkA "聪明" ;
lin cloud_N = mkN "云" ;
lin cold_A = mkA "冷" ;
lin come_V = mkV "来" ;
lin computer_N = mkN "电脑" ;
lin cow_N = mkN "牛" ;
lin dirty_A = mkA "脏" ;
lin dog_N = mkN "狗" ;
lin drink_V2 = mkV2 (mkV "喝") ;
lin eat_V2 = mkV2 (mkV "吃") ;
lin find_V2 = mkV2 (mkV "找到") ;
lin fire_N = mkN "火" ;
lin fish_N = mkN "鱼" ;
lin flower_N = mkN "花" ;
lin friend_N = mkN "朋友" ;
lin girl_N = mkN "女孩" ;
lin good_A = mkA "好" ;
lin go_V = mkV "去" ;
lin grammar_N = mkN "语法" ;
lin green_A = mkA "绿" ;
lin heavy_A = mkA "重" ;
lin horse_N = mkN "马" ;
lin hot_A = mkA "热" ;
lin house_N = mkN "房子" ;
-- lin john_PN = mkPN "约翰" ;
lin jump_V = mkV "跳" ;
lin kill_V2 = mkV2 "杀" ;
-- lin know_VS = mkVS (mkV "知道") ;
lin language_N = mkN "语言" ;
lin live_V = mkV "住" ;
lin love_V2 = mkV2 (mkV "爱") ;
lin man_N = mkN "男人" "男人们" ;
lin milk_N = mkN "牛奶" ;
lin music_N = mkN "音乐" ;
lin new_A = mkA "新" ;
lin now_Adv = mkAdv "现在" ;
lin old_A = mkA "老" ;
-- lin paris_PN = mkPN "巴黎" ;
lin play_V = mkV "玩" ;
lin read_V2 = mkV2 (mkV "读") ;
lin ready_A = mkA "准备好" ;
lin red_A = mkA "红" ;
lin river_N = mkN "河" ;
lin run_V = mkV "跑" ;
lin sea_N = mkN "海" ;
lin see_V2 = mkV2 (mkV "看见") ;
lin ship_N = mkN "船" ;
lin sleep_V = mkV "睡" ;
lin small_A = mkA "小" ;
lin star_N = mkN "星星" ;
lin swim_V = mkV "游泳" ;
lin teach_V2 = mkV2 (mkV "教") ;
lin train_N = mkN "火车" ;
lin travel_V = mkV "旅行" ;
lin tree_N = mkN "树" ;
lin understand_V2 = mkV2 (mkV "理解") ;
lin wait_V2 = mkV2 "等" "等" ;
lin walk_V = mkV "走" ;
lin warm_A = mkA "暖和" ;
lin water_N = mkN "水" ;
lin white_A = mkA "白" ;
lin wine_N = mkN "葡萄酒" ;
lin woman_N = mkN "女人" "女人们" ;
lin yellow_A = mkA "黄" ;
lin young_A = mkA "年轻" ;

---------------------------
-- Paradigms part ---------
---------------------------

oper
  mkN = overload {
  mkN : Str -> Noun = \n -> lin N (mkNoun n n) ;
  mkN : Str -> Str -> Noun = \sg,pl -> lin N (mkNoun sg pl) ;
  } ;

  mkA : Str -> A
    = \s -> lin A {s = s} ;

  mkV : Str -> V = \s -> lin V {s = s} ;

  mkV2 = overload {
    mkV2 : Str -> V2 = \s -> lin V2 ({s = s} ** {c = ""}) ;
    mkV2 : Str -> Str -> V2 = \s,prep -> lin V2 ({s = s} ** {c = prep}) ;
    mkV2 : V -> V2 = \v -> lin V2 (v ** {c = ""}) ;
    mkV2 : V -> Str -> V2 = \v,prep -> lin V2 (v ** {c = prep}) ;
  } ;

  mkAdv : Str -> Adv
    = \s -> lin Adv {s = s} ;

  mkPrep : Str -> Str -> Prep
  = \p, l -> lin Prep {prep = p ; loc = l} ;

}
