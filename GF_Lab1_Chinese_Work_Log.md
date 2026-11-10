# GF Lab 1 — Chinese Grammar Implementation Work Log

**Date:** November 2026  
**Project:** Computational Syntax — Lab 1  
**Language:** Chinese (`MicroLangChi`)  
**Branch:** `chinese-grammar-practice`  
**Repository:** `comp-syntax-gu-mlt-git-backup`

---
## Future Improvements & Known Limitations

The current implementation provides a working basic Chinese concrete syntax for Lab 1. However, it uses simplified grammatical representations and does not attempt to cover the full complexity of Mandarin Chinese.

The following points are potential improvements for future work. They are not necessarily required for the current Lab 1 implementation.

### 1. Chinese noun phrases and classifiers

**Current limitation:**

- `DetCN` ignores number distinctions in noun realization.
- All determiners (`a_Det`, `aPl_Det`, `the_Det`, `thePl_Det`) have empty surface forms.
- Chinese classifiers (量词), such as 一本书 and 一个学生, are not implemented.

**Possible improvement:**

Introduce classifiers and a more natural representation of Chinese noun phrases, including demonstratives and numeral-classifier constructions.

### 2. Adjective predicates

**Current limitation:**

`UseComp` uses an empty verb instead of an overt copula:

```gf
UseComp comp = {
  beforeVerb = [];
  verb = mkVerb "";
  compl = comp.s
};
```

This allows simple adjective predicates but may generate unnatural expressions such as:

- 她 红
- 火 温暖

**Possible improvement:**

Explore the use of 很 and other degree markers in Chinese adjective predicates, while considering that 很 is not always necessary.

### 3. Adverbial ordering and placement

**Current limitation:**

`AdvVP` currently appends new adverbials to `beforeVerb`:

```gf
AdvVP vp adv =
  vp ** {beforeVerb = vp.beforeVerb ++ adv.s};
```

This supports basic adverb placement before verbs, but does not distinguish different types of adverbials or their preferred ordering.

**Possible improvement:**

Investigate the ordering of time, frequency, manner and location adverbials in Chinese.

### 4. Prepositional phrase constructions

**Current limitation:**

The current `Prep` type uses two strings:

```gf
Prep = {
  beforeNP : Str;
  afterNP : Str
};
```

This supports simple constructions such as:

- 在房间里
- 在桌子上
- 和他一起

However, it does not cover the full range of Chinese coverbs, prepositions and locative constructions.

**Possible improvement:**

Distinguish different types of prepositional or coverb constructions and examine their syntactic positions.

### 5. Agreement and grammatical features

**Current limitation:**

`NP` and `Pron` contain an `Agreement` field, but the current linearization rules do not make use of it.

```gf
NP = {
  s : Case => Str;
  a : Agreement
};
```

**Possible improvement:**

Investigate whether agreement features are needed for future grammatical constructions, and whether the current representation can be simplified without losing compatibility with the abstract syntax.

### 6. Verb complements and argument structure

**Current limitation:**

`Verb2` extends `Verb` with a single string field `c`:

```gf
Verb2 : Type = Verb ** {c : Str};
```

This is sufficient for the current simplified treatment of transitive verbs and additional complement markers, but it does not model the full range of Chinese verb argument structures.

**Possible improvement:**

Explore different verb-complement patterns, including verbs with prepositional complements, resultative complements and other argument structures.

### 7. Linguistic naturalness and semantic compatibility

**Current limitation:**

Random generation can produce grammatically composable but semantically or linguistically unnatural strings.

For example:

- 他们 在 她 里 玩

The grammar currently combines lexical items without semantic selection restrictions.

**Possible improvement:**

Improve lexical selection, semantic compatibility and the naturalness of generated sentences.

### 8. Resource Grammar Library (RGL) compatibility

**Current status:**

The grammar compiles and passes the current targeted tests, but comprehensive compatibility testing with the RGL has not yet been documented.

**Possible improvement:**

Test the implementation against the relevant RGL interfaces and investigate whether additional language-specific structures or adaptations are needed.

---

**Priority note:** The most useful areas for further linguistic development would probably be classifiers and noun phrases, adjective predicates, and adverbial ordering. The remaining points can be explored when relevant to later coursework.

**Current decision:** These limitations are documented as future development opportunities rather than unfinished tasks. The basic Lab 1 implementation is preserved as a working milestone.

## 1. Project Setup

Started working on the Chinese implementation of Lab 1 using the backup repository.

Working directory:

```bash
~/Desktop/comp-syntax-gu-mlt-git-backup/lab1/grammar/chinese
```

GF version:

```text
GF 3.11.0
```

GF shell command:

```bash
/Users/shuyu/GF/bin/gf -path ~/gf-rgl/src/prelude:../abstract
```

Loaded the Chinese concrete syntax:

```gf
i MicroLangChi.gf
```

The grammar loaded successfully.

**Important project decision:**

The teacher-provided abstract syntax file `MicroLang.gf` was kept unchanged. All language-specific modifications were made in:

- `MicroLangChi.gf`
- `MicroResChi.gf`

---

## 2. Changes to MicroResChi.gf

### 2.1 Simplified noun morphology

Changed the noun representation to:

```gf
Noun : Type = {s : Str};

mkNoun : Str -> Noun = \word -> {
  s = word
};
```

**Reason:**

Chinese nouns do not normally change their form according to singular and plural number.

For example:

- book → 书
- books → 书

Therefore, the English-style number-dependent noun forms were removed from the simplified Chinese resource grammar.

### 2.2 Simplified adjective representation

Defined:

```gf
Adjective : Type = {s : Str};
```

Chinese adjectives are represented by a single string form in the current implementation.

### 2.3 Simplified verb morphology

Changed the verb representation to:

```gf
Verb : Type = {s : Str};

mkVerb : Str -> Verb = \word -> {
  s = word
};
```

**Reason:**

Chinese verbs do not require the English-style inflectional forms used in the original English resource grammar.

For example:

- go / goes / went / gone → 去
- eat / eats / ate / eaten → 吃

The following English-specific verb morphology was no longer needed:

- `VForm`
- `regVerb`
- `smartVerb`
- `irregVerb`
- `agr2vform`

### 2.4 Defined number, case and agreement parameters

```gf
param
  Number = Sg | Pl;
  Case = Nom | Acc;
  Agreement = Agr Number;
```

These parameters preserve the grammatical distinctions used by the abstract syntax.

Although Chinese nouns and pronouns do not generally change form according to grammatical case, the current implementation retains `Nom` and `Acc` for compatibility with the grammar structure.

### 2.5 Defined Verb2

```gf
Verb2 : Type = Verb ** {c : Str};
```

`Verb2` extends the ordinary `Verb` type with an additional field `c`.

- `s`: the verb itself.
- `c`: an additional complement marker or preposition.

For ordinary transitive verbs, `c` is an empty string.

This allows the grammar to represent both direct-object verbs and verbs requiring an additional preposition or complement marker.

---

## 3. Changes to MicroLangChi.gf

### 3.1 Updated linearization categories

The main linearization categories were adapted to Chinese:

```gf
lincat
  Utt = {s : Str};
  S = {s : Str};

  VP = {
    beforeVerb : Str;
    verb : Verb;
    compl : Str
  };

  Comp = {s : Str};
  AP = Adjective;
  CN = Noun;

  NP = {
    s : Case => Str;
    a : Agreement
  };

  Pron = {
    s : Case => Str;
    a : Agreement
  };

  Det = {
    s : Str;
    n : Number
  };

  Prep = {
    beforeNP : Str;
    afterNP : Str
  };

  V = Verb;
  V2 = Verb2;
  A = Adjective;
  N = Noun;
  Adv = {s : Str};
```

### 3.2 Changed VP structure to support Chinese word order

The VP representation was expanded:

```gf
VP = {
  beforeVerb : Str;
  verb : Verb;
  compl : Str
};
```

This makes it possible to place adverbs and prepositional phrases before the verb.

The resulting simplified Chinese structure is:

```text
Subject + Adverbial + Verb + Complement
```

For example:

```text
她 已经 跑
```

### 3.3 Implemented PredVPS

```gf
PredVPS np vp = {
  s = np.s ! Nom ++ vp.beforeVerb ++ vp.verb.s ++ vp.compl
};
```

The subject uses the nominative form, followed by the material before the verb, the verb itself, and its complement.

### 3.4 Updated UseV

```gf
UseV v = {
  beforeVerb = [];
  verb = v;
  compl = []
};
```

Initializes an intransitive VP with no preceding adverbial and no complement.

### 3.5 Updated ComplV2

```gf
ComplV2 v2 np = {
  beforeVerb = [];
  verb = v2;
  compl = v2.c ++ np.s ! Acc
};
```

Combines a transitive verb with its object NP.

The object uses the accusative form.

### 3.6 Simplified adjective predicates

Changed `UseComp` to:

```gf
UseComp comp = {
  beforeVerb = [];
  verb = mkVerb "";
  compl = comp.s
};
```

The copula is represented by an empty string because Chinese adjective predicates do not normally require the verb 是 in the same way English adjective predicates require *be*.

For example, the simplified grammar can generate:

```text
她 红
```

This is a deliberately simplified representation. More natural Chinese expressions may require 很 or other constructions, which are outside the current implementation.

### 3.7 Implemented AdvVP

```gf
AdvVP vp adv =
  vp ** {beforeVerb = vp.beforeVerb ++ adv.s};
```

This places adverbials before the verb.

For example:

```text
她 已经 跑
```

The implementation also supports multiple adverbials through repeated `AdvVP` applications.

The current concatenation order preserves the existing adverbial material first, followed by the newly added adverbial.

### 3.8 Simplified DetCN

```gf
DetCN det cn = {
  s = \\c => det.s ++ cn.s;
  a = Agr det.n
};
```

The noun itself does not change according to number.

The determiner retains its number feature, but the current Chinese determiners have empty surface forms:

```gf
a_Det = {s = ""; n = Sg};
aPl_Det = {s = ""; n = Pl};
the_Det = {s = ""; n = Sg};
thePl_Det = {s = ""; n = Pl};
```

This is a simplified treatment. Chinese classifiers and demonstratives are not implemented here.

### 3.9 Implemented adjective–noun order

```gf
AdjCN ap cn = {
  s = ap.s ++ cn.s
};
```

Chinese adjectives precede nouns.

For example:

```text
新 河流
```

### 3.10 Implemented pronouns

Pronouns were represented with both nominative and accusative forms:

```gf
he_Pron = {
  s = table {Nom => "他"; Acc => "他"};
  a = Agr Sg
};

she_Pron = {
  s = table {Nom => "她"; Acc => "她"};
  a = Agr Sg
};

they_Pron = {
  s = table {Nom => "他们"; Acc => "他们"};
  a = Agr Pl
};
```

Chinese pronouns retain the same surface form in subject and object positions in this simplified grammar.

### 3.11 Implemented prepositional phrases

Changed the Prep representation to:

```gf
Prep = {
  beforeNP : Str;
  afterNP : Str
};
```

Implemented:

```gf
PrepNP prep np = {
  s = prep.beforeNP ++ np.s ! Acc ++ prep.afterNP
};
```

The three prepositions were defined as:

```gf
in_Prep = {
  beforeNP = "在";
  afterNP = "里"
};

on_Prep = {
  beforeNP = "在";
  afterNP = "上"
};

with_Prep = {
  beforeNP = "和";
  afterNP = "一起"
};
```

This allows the grammar to represent Chinese prepositional structures with both pre-NP and post-NP material.

Examples:

- 在房间里
- 在桌子上
- 和他一起

### 3.12 Updated mkPrep

The resource constructor was adapted to the new Prep structure:

```gf
mkPrep : Str -> Str -> Prep
  = \before, after -> lin Prep {
      beforeNP = before;
      afterNP = after
    };
```

---

## 4. Lexicon and Paradigms

The Chinese lexicon was implemented using simplified constructors.

Examples:

```gf
lin book_N = mkN "书";
lin good_A = mkA "好";
lin go_V = mkV "去";
lin break_V2 = mkV2 (mkV "打破");
lin eat_V2 = mkV2 (mkV "吃");
```

The `mkV2` overload supports:

- `Str -> V2`
- `Str -> Str -> V2`
- `V -> V2`
- `V -> Str -> V2`

This allows the lexicon to define transitive verbs with or without additional complement markers.

The lexicon was translated into Chinese while preserving the teacher-provided abstract syntax.

---

## 5. Testing and Verification

### 5.1 Compilation

Loaded the grammar successfully:

```gf
i MicroLangChi.gf
```

Result:

```text
linking ... OK
Languages: MicroLangChi
```

### 5.2 Random generation

Ran:

```gf
gr -number=20 | l
```

The grammar generated 20 Chinese strings successfully.

Examples:

```text
她 来
他 和 他们 一起 生活
他们 读 他们
河流 已经 杀死 他
她 已经 跑
朋友 现在 玩
他们 在 她 里 玩
```

Some generated strings are semantically or linguistically unnatural because the random generator combines lexical items without considering their semantic compatibility.

However, the output demonstrates that the grammar can combine its categories and linearize generated trees.

### 5.3 Targeted tests

Four targeted tests were performed successfully.

**Test 1: Subject + intransitive verb**

```gf
l (PredVPS (UsePron she_Pron) (UseV go_V))
```

Output:

```text
她 去
```

**Test 2: Subject + transitive verb + object**

```gf
l (PredVPS (UsePron he_Pron)
    (ComplV2 break_V2 (UsePron she_Pron)))
```

Output:

```text
他 打破 她
```

**Test 3: Prepositional phrase**

```gf
l (PrepNP in_Prep (UsePron he_Pron))
```

Output:

```text
在 他 里
```

This confirms the intended order:

```text
beforeNP + NP + afterNP
```

**Test 4: Adverb + verb**

```gf
l (PredVPS (UsePron she_Pron)
    (AdvVP (UseV run_V) already_Adv))
```

Output:

```text
她 已经 跑
```

All four targeted tests passed.

---

## 6. Git Status

Current branch:

```text
chinese-grammar-practice
```

Final status check:

```bash
git status
```

Output:

```text
On branch chinese-grammar-practice
nothing to commit, working tree clean
```

This confirms that there are no uncommitted changes in the working tree.

The clean working tree does not by itself confirm whether all local commits have been pushed to the remote repository.

---

## 7. Current Status and Future Scope

The basic Chinese grammar implementation is substantially complete.

Completed:

- Simplified Chinese noun, adjective and verb representations.
- Basic NP, VP, AP, CN and Prep linearization types.
- Subject–predicate structure.
- Transitive and intransitive verb constructions.
- Adjective–noun order.
- Prepositional phrase structure.
- Adverb placement before verbs.
- Chinese pronoun forms.
- Lexicon and paradigm constructors.
- Successful compilation, random generation and four targeted tests.

Potential future improvements, not required for the current basic implementation:

- More natural adjective predicates, e.g. adding 很 where appropriate.
- Chinese classifiers and more sophisticated determiner constructions.
- More detailed treatment of aspect, tense and other Chinese grammatical features.
- More natural adverbial ordering and semantic constraints.
- Further compatibility testing with the Resource Grammar Library (RGL).

**Decision:** Stop expanding the current implementation for now. Preserve the completed work and move on to other course material rather than spending excessive time polishing a deliberately simplified grammar.

**Overall result:** A working basic Chinese concrete syntax for the Lab 1 grammar, with successful compilation and targeted linearization tests.