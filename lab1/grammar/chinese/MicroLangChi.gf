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
    Prep = {s : Str} ;
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
      verb = mkVerb "" ;    
      compl = comp.s
      } ;
      
    CompAP ap = ap ;
      
    AdvVP vp adv =
      vp ** {compl = vp.compl ++ adv.s} ;
      
    DetCN det cn = {
      s = \\c => det.s ++ cn.s ;
      a = Agr det.n ;
      } ;
      
    UsePron p = p ;
            
    a_Det = {s = "" ; n = Sg} ; 
    aPl_Det = {s = "" ; n = Pl} ;
    the_Det = {s = "" ; n = Sg} ;
    thePl_Det = {s = "" ; n = Pl} ;
    
    UseN n = n ;
    
    AdjCN ap cn = {
      s = ap.s ++ cn.s
      } ;

    PositA a = a ;

    PrepNP prep np = {s = prep.s ++ np.s ! Acc} ;

    in_Prep = {s = "in"} ;
    on_Prep = {s = "on"} ;
    with_Prep = {s = "with"} ;

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

lin already_Adv = mkAdv "已经" ; -- already
lin animal_N = mkN "动物" ; -- animal
lin apple_N = mkN "苹果" ; -- apple
lin baby_N = mkN "婴儿" ; -- baby
lin bad_A = mkA "坏" ; -- bad
lin beer_N = mkN "啤酒" ; -- beer
lin big_A = mkA "大" ; -- big
lin bike_N = mkN "自行车" ; -- bike
lin bird_N = mkN "鸟" ; -- bird
lin black_A = mkA "黑" ; -- black
lin blood_N = mkN "血" ; -- blood
lin blue_A = mkA "蓝" ; -- blue
lin boat_N = mkN "船" ; -- boat
lin book_N = mkN "书" ; -- book
lin boy_N = mkN "男孩" ; -- boy
lin bread_N = mkN "面包" ; -- bread
lin break_V2 = mkV2 (mkV "打破") ; -- break, broke, broken
lin buy_V2 = mkV2 (mkV "买") ; -- buy, bought, bought
lin car_N = mkN "汽车" ; -- car
lin cat_N = mkN "猫" ; -- cat
lin child_N = mkN "孩子" ; -- child, children
lin city_N = mkN "城市" ; -- city
lin clean_A = mkA "干净" ; -- clean
lin clever_A = mkA "聪明" ; -- clever
lin cloud_N = mkN "云" ; -- cloud
lin cold_A = mkA "冷" ; -- cold
lin come_V = mkV "来" ; -- come, came, come
lin computer_N = mkN "电脑" ; -- computer
lin cow_N = mkN "奶牛" ; -- cow
lin dirty_A = mkA "脏" ; -- dirty
lin dog_N = mkN "狗" ; -- dog
lin drink_V2 = mkV2 (mkV "喝") ; -- drink, drank, drunk
lin eat_V2 = mkV2 (mkV "吃") ; -- eat, ate, eaten
lin find_V2 = mkV2 (mkV "找到") ; -- find, found, found
lin fire_N = mkN "火" ; -- fire
lin fish_N = mkN "鱼" ; -- fish, fish
lin flower_N = mkN "花" ; -- flower
lin friend_N = mkN "朋友" ; -- friend
lin girl_N = mkN "女孩" ; -- girl
lin good_A = mkA "好" ; -- good
lin go_V = mkV "去"; -- go, went, gone
lin grammar_N = mkN "语法" ; -- grammar
lin green_A = mkA "绿" ; -- green
lin heavy_A = mkA "重" ; -- heavy
lin horse_N = mkN "马" ; -- horse
lin hot_A = mkA "热" ; -- hot
lin house_N = mkN "房子" ; -- house
-- lin john_PN = mkPN "John" ;
lin jump_V = mkV "跳" ; -- jump
lin kill_V2 = mkV2 "杀死" ; -- kill
-- lin know_VS = mkVS (mkV "know" "knew" "known") ;
lin language_N = mkN "语言" ; -- language
lin live_V = mkV "生活" ; -- live
lin love_V2 = mkV2 (mkV "爱") ; -- love
lin man_N = mkN "男人" ; -- man, men
lin milk_N = mkN "牛奶" ; -- milk
lin music_N = mkN "音乐" ; -- music
lin new_A = mkA "新" ; -- new
lin now_Adv = mkAdv "现在" ; -- now
lin old_A = mkA "老" ; -- old
-- lin paris_PN = mkPN "Paris" ;
lin play_V = mkV "玩" ; -- play
lin read_V2 = mkV2 (mkV "读") ; -- read, read, read
lin ready_A = mkA "准备好" ; -- ready
lin red_A = mkA "红" ; -- red
lin river_N = mkN "河流" ; -- river
lin run_V = mkV "跑"; -- run, ran, run
lin sea_N = mkN "海" ; -- sea
lin see_V2 = mkV2 (mkV "看见") ; -- see, saw, seen
lin ship_N = mkN "船" ; -- ship
lin sleep_V = mkV "睡觉" ; -- sleep, slept, slept
lin small_A = mkA "小" ; -- small
lin star_N = mkN "星星" ; -- star
lin swim_V = mkV "游泳" ; -- swim, swam, swum
lin teach_V2 = mkV2 (mkV "教") ; -- teach, taught, taught
lin train_N = mkN "火车" ; -- train
lin travel_V = mkV "旅行" ; -- travel
lin tree_N = mkN "树" ; -- tree
lin understand_V2 = mkV2 (mkV "理解") ; -- understand, understood, understood
lin wait_V2 = mkV2 "等待" ; -- wait for
lin walk_V = mkV "走路" ; -- walk
lin warm_A = mkA "温暖" ; -- warm
lin water_N = mkN "水" ; -- water
lin white_A = mkA "白" ; -- white
lin wine_N = mkN "葡萄酒" ; -- wine
lin woman_N = mkN "女人" ; -- woman, women
lin yellow_A = mkA "黄" ; -- yellow
lin young_A = mkA "年轻" ; -- young


---------------------------
-- Paradigms part ---------
---------------------------

oper
  mkN : Str -> Noun   
      = \n -> lin N (mkNoun n) ;

  mkA : Str -> A
    = \s -> lin A {s = s} ;

  mkV : Str -> V = \s -> lin V (mkVerb s) ;

  mkV2 = overload {
    mkV2 : Str -> V2          -- predictable verb with direct object, e.g. "wash"
      = \s   -> lin V2 (mkVerb s ** {c = []}) ;
    mkV2 : Str  -> Str -> V2  -- predictable verb with preposition, e.g. "wait - for"
      = \s,p -> lin V2 (mkVerb s ** {c = p}) ;
    mkV2 : V -> V2            -- any verb with direct object, e.g. "drink"
      = \v   -> lin V2 (v ** {c = []}) ;
    mkV2 : V -> Str -> V2     -- any verb with preposition
      = \v,p -> lin V2 (v ** {c = p}) ;
    } ;

  mkAdv : Str -> Adv
    = \s -> lin Adv {s = s} ;
  
  mkPrep : Str -> Prep
    = \s -> lin Prep {s = s} ;

}
