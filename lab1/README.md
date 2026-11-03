# Lab 1: Multilingual generation and translation

In this lab, you will implement the concrete syntax of a grammar for a language of your choice. 
The abstract syntax is given in the directory [`grammar/abstract/`](grammar/abstract/) and an example concrete syntax for English can be found in [`grammar/english/`](grammar/english/).

You will need to install:

- GF core and the RGL (see installation instructions [here](https://www.grammaticalframework.org/download/index-3.11.html)) 
- the [language server for GF](https://github.com/anka-213/gf-lsp)

## Part 1: setup and lexicon
1. Create a subfolder in [`grammar/`](grammar/) for your language of choice
2. Copy the contents of [`grammar/english/`](grammar/english/) to your new folder and apply the necessary renamings (i.e. replace all occurrences of `Eng` with the new language code)
3. Translate the words in lexicon part of `MicroLangXxx`
4. Test your new concrete syntax by generating a few random trees in the GF interpreter. When you linearize them, you should see sentences in a mixture of English and your chosen language. To do this you can use the commands
     - `i MicroLangXxx.gf` to [import](https://www.grammaticalframework.org/doc/gf-shell-reference.html#toc18) the grammar
     - `gr | l` to [generate a random tree](https://www.grammaticalframework.org/doc/gf-shell-reference.html#toc15) and [linearize](https://www.grammaticalframework.org/doc/gf-shell-reference.html#toc19) it

## Part 2: morphology
1. Design the morphological types of the major parts of speech (NOUN, ADJ, and VERB) in your selected language, i.e. identify their inflectional and inherent features using: a traditional grammar book or a Wikipedia article __and/or__ data from [universaldependencies.org](https://universaldependencies.org/). In the latter case:
     1. download a treebank for your language
     2. use [deptreepy](https://github.com/aarneranta/deptreepy/) or write your own script to query the treebank and look up what morphological features actually occur in the data for each POS
2. Implement these in GF by defining parameters and writing a couple of paradigms. In this phase, you will work in the `MicroResXxx` module
3. Test your GF morphology. To do that, you can import the grammar with the `-retain` flag and use the [`compute_concrete`](https://www.grammaticalframework.org/doc/gf-shell-reference.html#toc8) command on the various lexical items. For example `cc star_N` returns the full inflectional table for the noun "star"

## Part 3: syntax
1. Define the linearization types of main phrasal categories - the remaining categories in `MicroLang`.
2. Define the rest of the linearization rules in `MicroLang`.

## Part 4: testing your grammar against the RGL
Since `MicroLang` is a proper part of the RGL, it can be easily implemented as an application grammar.
How to do this is shown in `grammar/functor/`, where the implementation consists of two files:
- `MicroLangFunctor.gf` which is a generic implementation working for all RGL languages,
- `MicroLangFunctorEng.gf` which is a *functor instantiation* for English, easily reproducible for other languages than `Eng`.

To use this for testing, you can take the following steps:

1. Build a functor instantiation for your language by copying `MicroLangFunctorEng.gf` and changing `Eng` in the file name and inside the file to your language code.

2. Use GF to create a testfile by random generation:
```
  $ echo "gr -number=1000 | l -tabtreebank" | gf english/MicroLangEng.gf functor/MicroLangFunctorEng.gf >test.tmp
```

3. Inspect the resulting file `test.tmp`.
But you can also use Unix `cut` to create separate files for the two versions of the grammar and `diff` to compare them:
```
  $ cut -f2 test.tmp >test1.tmp
  $ cut -f3 test.tmp >test2.tmp
  $ diff test1.tmp test2.tmp

  52c52
  < the hot fire teachs her
  ---
  > the hot fire teaches her
  69c69
  < the man teachs the apples
  ---
  > the man teaches the apples
  122c122
  ```
As seen from the result in this case, our implementation has a wrong inflection of the verb "teach".

The Mini grammar can be tested in the same way, by building a reference implementation using the functor in `functor/`.'

---

Submit `MicroLangXxx.gf` and `MicroResXxx.gf` on Canvas.

很好！这份 `MicroLangEng.gf` 很值得仔细研究。我们现在已经进入真正的 GF 编程部分了。

我先不急着让你写中文版本，而是带你理解这份文件的整体结构，并指出几个中文实现时需要特别留意的地方。

## 1. 先看文件开头：Module declaration

```
--# -path=.:../abstract
concrete MicroLangEng of MicroLang = open MicroResEng, Prelude in {
```

这里有四个重要概念：

| 代码                          | 含义           |
| --------------------------- | ------------ |
| `concrete`                  | 声明一个具体语法模块   |
| `MicroLangEng`              | 当前模块名称       |
| `of MicroLang`              | 当前模块实现哪个抽象语法 |
| `open MicroResEng, Prelude` | 引入其他模块中的定义   |

特别注意：

```
concrete MicroLangEng of MicroLang
```

它表示：`MicroLangEng` 必须实现 `MicroLang` 抽象语法中规定的所有函数。

而：

```
open MicroResEng, Prelude
```

表示可以使用这两个模块提供的定义。

`MicroResEng` 很可能包含英语的形态学资源，例如名词、动词和形容词的构造方式。稍后我们需要查看它的代码，才能确认具体实现。

## 2. Grammar part：定义语法类别的线性化类型

这是第一块非常重要的内容：

```
lincat
  Utt = {s : Str} ;
  S  = {s : Str} ;
  VP = {verb : Verb ; compl : Str} ;
  Comp = {s : Str} ;
  AP = Adjective ;
  CN = Noun ;
  NP = {s : Case => Str ; a : Agreement} ;
```

这里的 `lincat` 是 `linearization category` 的缩写。

简单说：

Abstract syntax 定义有哪些语法类别；lincat 定义这些类别在具体语言中由什么数据结构表示。

例如：

```
S = {s : Str} ;
```

意思是，一个句子 `S` 在英语中由一个记录（record）表示，其中有一个字段 `s`，类型是 `Str`。

`Str` 可以理解为 GF 中的字符串类型。

再看：

```
NP = {s : Case => Str ; a : Agreement} ;
```

这就复杂一些了：

- `s`：一个根据 Case 变化的字符串。
- `Case => Str`：一个从 Case 到 Str 的表（table）。
- `a`：Agreement，表示一致关系。

例如英语代词：

| Case       | 形式  |
| ---------- | --- |
| Nominative | he  |
| Accusative | him |

所以：

```
he_Pron = {
  s = table {Nom => "he" ; Acc => "him"} ;
  a = Agr Sg ;
} ;
```

这里的 `table` 是一个非常重要的 GF 结构。

它让同一个词汇项目可以根据语法条件选择不同形式。

对中文来说，这里会出现一个值得思考的问题：中文代词是否需要像英语一样区分主格和宾格？

我们先不要急着修改，后面设计中文的 `NP` 类型时再决定如何处理。

## 3. lin：定义具体的线性化规则

例如：

```
lin
  UttS s = s ;
  UttNP np = {s = np.s ! Acc} ;
```

`lin` 是 linearization rules。

这里：

```
UttS s = s ;
```

表示一个由句子构成的 utterance，直接使用句子的线性化结果。

再看：

```
UttNP np = {s = np.s ! Acc} ;
```

其中最值得注意的是：

```
!
```

在 GF 中，`!` 用于从 table 中取出某个对应的值。

因此：

```
np.s ! Acc
```

就是从 NP 的 `s` table 中取出 Accusative（宾格）形式。

这也是为什么前面 `NP` 定义了：

```
s : Case => Str
```

两部分是相互关联的。

## 4. 重点看 DetCN：英语的名词短语结构

```
DetCN det cn = {
  s = \\c => det.s ++ cn.s ! det.n ;
  a = Agr det.n ;
} ;
```

这段以后很可能需要重点修改。

先拆开看：

| 符号             | 含义                                 |
| -------------- | ---------------------------------- |
| `\\c =>`       | 定义一个接受参数 `c` 的函数（这里的双反斜杠是 GF 源码写法） |
| `++`           | 字符串拼接                              |
| `!`            | 从 table 中选择一个值                     |
| `det.n`        | 冠词所携带的 Number                      |
| `cn.s ! det.n` | 根据 Number 选择名词形式                   |

例如：

```
the + apple
```

英语的 `DetCN` 会把 determiner 和 noun 组合起来。

但是中文通常不使用英语这种冠词系统，而是会有：

```
这 + 个 + 苹果
```

或者：

```
一个 + 苹果
```

这意味着我们不能简单地把 English 的 `DetCN` 原样翻译成中文。我们需要根据中文的表达方式重新设计它。

## 5. Lexicon part：词汇表

例如：

```
lin already_Adv = mkAdv "already" ;
lin animal_N = mkN "animal" ;
lin bad_A = mkA "bad" ;
lin break_V2 = mkV2 (mkV "break" "broke" "broken") ;
```

这里开始把抽象语法中的词汇函数映射到英语词汇。

例如：

```
lin animal_N = mkN "animal" ;
```

可以理解为：

- `animal_N`：抽象语法中的词汇名称。
- `mkN`：构造一个名词的操作。
- `"animal"`：英语词汇形式。

注意，`mkN` 不是 GF 内置的普通英文单词，而是在这个模块的 `oper` 部分定义的操作。

## 6. Paradigms part：自己定义的操作

文件最后：

```
oper
  mkN = overload {
    mkN : Str -> Noun
      = \n -> lin N (smartNoun n) ;

    mkN : Str -> Str -> Noun
      = \sg,pl -> lin N (mkNoun sg pl) ;
  } ;
```

这里有一个值得学习的概念：overload（重载）。

同一个 `mkN` 可以接受不同数量的参数。

第一种：

```
mkN "animal"
```

只提供单数形式，系统根据英语规则推导复数。

第二种：

```
mkN "child" "children"
```

直接提供单数和复数，因为 `child` 的复数不规则。

这就是为什么 Lexicon 中有：

```
lin child_N = mkN "child" "children" ;
```

而普通名词只需要：

```
lin animal_N = mkN "animal" ;
```

对于中文来说，名词通常没有英语这种单复数词形变化。这会影响我们后面如何设计 `MicroResChi`。

## 7. 我希望你先记住的几个 GF 符号

| GF 符号   | 含义                                    |
| ------- | ------------------------------------- |
| `=`     | 定义或赋值                                 |
| `:`     | 类型声明                                  |
| `;`     | 结束一个定义                                |
| `->`    | 函数类型                                  |
| `=>`    | table 类型                              |
| `!`     | table 取值                              |
| `++`    | 字符串拼接                                 |
| `\\`    | lambda 函数定义（源码中写作两个反斜杠）               |
| `**`    | record extension / record combination |
| `table` | 创建一个表格结构                              |
| `oper`  | 定义可复用的操作                              |

## 8. 下一步：先看 MicroResEng.gf

重点：Prelude 是模块名称，prelude 是存放相关 GF 源文件的目录。 两者不要混为一谈。


好的，这份 `MicroResEng.gf` 是一个 GF（Grammatical Framework）资源语法文件。它主要定义了英语中几类基本词汇的形态变化规则（morphology），包括名词、动词、形容词，以及主谓一致所需的参数。

我先帮你梳理一下整体结构，方便我们后面继续分析。

## 1. 文件整体结构

```
resource MicroResEng = open Prelude in {

  param
    ...

  oper
    ...

}
```

这里有三个重要部分：

- `resource MicroResEng`：定义一个名为 `MicroResEng` 的 resource module。
- `open Prelude`：引入 GF Prelude 中定义的操作、类型和其他基础内容。
- `param`：定义语法参数（grammar parameters）。
- `oper`：定义可复用的操作、类型和函数（operations）。

## 2. param：定义语法参数

这一部分定义了英语语法中需要区分的不同类别。

| 定义                       | 含义            |
| ------------------------ | ------------- |
| `Number = Sg \\| Pl`     | 单数和复数         |
| `Case = Nom \\| Acc`     | 主格和宾格         |
| `Agreement = Agr Number` | 主谓一致，目前只考虑单复数 |
| `VForm`                  | 动词的五种形态       |

特别注意：

```
Agreement = Agr Number ;
```

这里的 `Agr` 是构造器（constructor），它把 `Number` 包装成 `Agreement`。

例如：

```
Agr Sg
Agr Pl
```

分别表示单数一致和复数一致。

而：

```
VForm = Inf | PresSg3 | Past | PastPart | PresPart ;
```

表示：

- `Inf`：动词原形，如 `eat`
- `PresSg3`：一般现在时第三人称单数，如 `eats`
- `Past`：过去式，如 `ate`
- `PastPart`：过去分词，如 `eaten`
- `PresPart`：现在分词，如 `eating`

## 3. oper：定义词类和形态变化函数

这是整个文件的核心。

### 3.1 Noun

```
Noun : Type = {s : Number => Str} ;
```

定义一个名词类型。

它包含一个字段 `s`，这个字段是一个 table，根据 Number 返回不同的字符串。

例如：

```
mkNoun : Str -> Str -> Noun = \sg,pl -> {
  s = table {Sg => sg ; Pl => pl}
} ;
```

如果调用：

```
mkNoun "cat" "cats"
```

就会得到：

```
{
  s = table {
    Sg => "cat" ;
    Pl => "cats"
  }
}
```

因此：

```
noun.s ! Sg
```

得到 `"cat"`，而：

```
noun.s ! Pl
```

得到 `"cats"`。

这里的 `!` 是 GF 的 table 查找操作。

### 3.2 regNoun 和 smartNoun

`regNoun` 是规则名词变化：

```
regNoun : Str -> Noun = \sg -> mkNoun sg (sg + "s") ;
```

例如：

```
regNoun "book"
```

得到 `book / books`。

`smartNoun` 则加入了一些常见的拼写变化：

| 单数结尾           | 复数变化    | 例子            |
| -------------- | ------- | ------------- |
| ay, ey, oy, uy | +s      | day → days    |
| 辅音 + y         | y → ies | city → cities |
| ch, sh, s, o   | +es     | bus → buses   |
| 其他             | +s      | book → books  |

它通过 `case ... of` 进行模式匹配。

## 4. Verb：动词类型

```
Verb : Type = {s : VForm => Str} ;
```

和 Noun 非常相似。

区别在于：

- Noun 根据 `Number` 返回不同形式。
- Verb 根据 `VForm` 返回不同形式。

例如：

```
mkVerb : (inf,pres,past,pastpart,prespart : Str) -> Verb
```

它接收五个字符串，分别代表动词的五种形式。

```
regVerb : (inf : Str) -> Verb = \inf ->
  mkVerb inf (inf + "s") (inf + "ed") (inf + "ed") (inf + "ing") ;
```

例如：

```
regVerb "walk"
```

得到：

| VForm    | 结果      |
| -------- | ------- |
| Inf      | walk    |
| PresSg3  | walks   |
| Past     | walked  |
| PastPart | walked  |
| PresPart | walking |

`smartVerb` 在此基础上进一步处理：

- 辅音 + y：try → tries / tried
- 辅音 + e：love → loves / loved / loving
- s, sh, x, o 结尾：kiss → kisses

`irregVerb` 则允许手动指定不规则动词的过去式和过去分词：

```
irregVerb "drink" "drank" "drunk"
```

它仍然使用 `smartVerb` 自动生成第三人称单数和现在分词。

## 5. Verb2：双价动词

```
Verb2 : Type = Verb ** {c : Str} ;
```

这里值得注意的是 `**`。

它表示 record extension / record combination：把两个 record 组合起来。

前面的 `Verb` 包含：

```
{s : VForm => Str}
```

后面的：

```
{c : Str}
```

包含一个额外字段 `c`，用于存储介词或格相关的信息。

注释说明：

```
-- two-place verb with "case" as preposition; for transitive verbs, c=[]
```

也就是说，这个类型可以表示需要两个论元的动词，并且允许记录一个介词。

## 6. be_Verb

```
be_Verb : Verb = mkVerb "are" "is" "was" "been" "being" ;
```

这里单独定义了 be 动词。

不过要留意：它目前并没有根据主语的人称和单复数完整区分形式。

例如：

- I am
- You are
- He is

目前这个资源只提供了一套简化的形式。

## 7. agr2vform：主谓一致

这是文件最后一个值得重点理解的函数：

```
agr2vform : Agreement -> VForm = \a -> case a of {
  Agr Sg => PresSg3 ;
  Agr Pl => Inf
} ;
```

它接收一个 `Agreement`，返回对应的动词形式。

| 输入       | 输出        |
| -------- | --------- |
| `Agr Sg` | `PresSg3` |
| `Agr Pl` | `Inf`     |

例如：

```
agr2vform (Agr Sg)
```

返回 `PresSg3`。

```
agr2vform (Agr Pl)
```

返回 `Inf`。

这样就可以实现：

- The cat walks.
- The cats walk.

## 8. 你现在最需要建立的整体理解

可以把这个文件理解成三层：

第一层：语法参数（param）

Number · Case · Agreement · VForm

定义需要区分哪些语法类别

第二层：词类的数据结构（Type）

Noun · Adjective · Verb · Verb2

定义每种词类包含什么信息

第三层：形态生成与语法转换（oper）

mkNoun · smartNoun · mkVerb · smartVerb · agr2vform

定义如何生成词形，以及如何根据语法参数选择词形

一个重要的区分： `MicroResEng.gf` 本身主要负责提供词汇和形态变化的基础设施，并不负责完整生成英语句子。句子的构造通常还需要其他模块，例如 `MicroEng.gf` 或 `MiniGrammar` 中的抽象语法和具体语法。

如果你正在重新理解之前的 Computational Syntax / GF 项目，我建议下一步重点看 `Noun : Type`、`Verb : Type` 和 `agr2vform`，因为这三个地方能帮助你理解 GF 如何把英语的语法规则转化成程序中的数据结构和函数。

这份 `MicroLangEng.gf` 非常值得仔细分析，因为它和上一份 `MicroResEng.gf` 的分工不一样。

如果说上一份文件主要负责定义英语单词内部的形态变化规则（morphology），那么这一份文件主要负责：

1. 定义抽象语法中的各个语法类别如何用英语表达。
2. 定义如何把名词、动词、形容词、代词等组合成短语和句子。
3. 定义具体的英语词汇（lexicon）。
4. 提供构造这些词汇的辅助函数（paradigms）。

从 GF 的角度来说，它是一个 Concrete Syntax（具体语法） 文件。

我们可以按照文件本身的四个部分来分析：

- Grammar part：语法结构和句子线性化规则。
- Lexicon part：词汇表。
- Paradigms part：词汇构造函数。
- 与 `MicroResEng.gf` 的关系：理解两个文件如何协作。

# 1. 文件整体结构

```
--# -path=.:../abstract
concrete MicroLangEng of MicroLang =
  open MicroResEng, Prelude in {

  lincat
    ...

  lin
    ...

  oper
    ...

}
```

先看第一行：

```
--# -path=.:../abstract
```

这是 GF 的编译路径设置。

- `.`：当前目录。
- `../abstract`：上一级目录下的 abstract 文件夹。

这使 GF 能够找到需要导入的模块。

接下来：

```
concrete MicroLangEng of MicroLang
```

这里有两个重要概念：

| 关键词            | 含义                    |
| -------------- | --------------------- |
| `concrete`     | 定义具体语法                |
| `of MicroLang` | 表示它实现抽象语法 `MicroLang` |

也就是说，应该存在另一个文件 `MicroLang.gf`，它定义了抽象语法。

例如，抽象语法可能定义：

```
cat
  S ;
  NP ;
  VP ;

fun
  PredVPS : NP -> VP -> S ;
```

这些定义只说明有哪些语法类别，以及它们之间如何组合，并不规定英语句子具体怎么排列。

而 `MicroLangEng.gf` 就负责规定这些抽象结构如何变成英语。

```
open MicroResEng, Prelude in
```

这里导入两个模块：

- `MicroResEng`：上一份文件，提供名词、动词、形容词等类型和形态变化函数。
- `Prelude`：GF 提供的基础模块。

因此，`MicroLangEng` 可以直接使用上一份文件中定义的 `Noun`、`Verb`、`Adjective`、`smartNoun`、`smartVerb` 等内容。

# 2. Grammar part：语法部分

这是整个文件最核心的部分。

它分成两个部分：

- `lincat`：Linearization Categories（线性化类别）
- `lin`：Linearization Rules（线性化规则）

## 2.1 lincat：定义抽象语法类别对应的数据结构

先看：

```
lincat
  Utt = {s : Str} ;
  S  = {s : Str} ;
  VP = {verb : Verb ; compl : Str} ;
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
```

这是一个非常重要的概念：

lincat 决定抽象语法中的每个 category，在具体语言中用什么数据结构来表示。

例如：

```
S = {s : Str} ;
```

表示抽象语法中的 `S`（Sentence）在英语中被表示成一个 record，其中有一个字段 `s`，保存整个句子的字符串。

比如：

```
The cat sleeps.
```

可以表示为：

```
{s = "The cat sleeps"}
```

再看几个比较重要的类别。

### A. VP：动词短语

```
VP = {verb : Verb ; compl : Str} ;
```

这里没有直接把 VP 定义成一个字符串，而是定义成一个包含两个字段的 record：

| 字段      | 类型     | 作用              |
| ------- | ------ | --------------- |
| `verb`  | `Verb` | 保存动词的不同形态       |
| `compl` | `Str`  | 保存动词的补足语或其他附加成分 |

例如：

```
eat an apple
```

可以先表示为：

```
{
  verb = eat 的动词形态表 ;
  compl = "an apple"
}
```

为什么不直接把 VP 定义成一个字符串？

因为英语动词需要根据主语决定形式。

例如：

- The boy eats an apple.
- The boys eat an apple.

如果在构造 VP 时就把动词固定成 `eats` 或 `eat`，就很难根据主语的单复数进行调整。

所以这里先保存完整的动词形态表，等到真正构造句子时，再选择正确的形式。

这是一个非常重要的设计。

### B. NP：名词短语

```
NP = {s : Case => Str ; a : Agreement} ;
```

NP 也不是简单的字符串，而是一个包含两个字段的 record。

| 字段  | 类型            | 作用           |
| --- | ------------- | ------------ |
| `s` | `Case => Str` | 根据格选择不同的表达形式 |
| `a` | `Agreement`   | 保存主谓一致信息     |

例如，代词：

| Case | he  | she | they |
| ---- | --- | --- | ---- |
| Nom  | he  | she | they |
| Acc  | him | her | them |

为什么 NP 需要 Case？

因为英语中的主格和宾格形式不同：

- He likes her.
- She likes him.

这里的 `he` 和 `him` 都属于同一个代词，但在不同的语法位置上需要使用不同的形式。

为什么还需要 Agreement？

因为主语还需要告诉动词应该选择什么形式：

- He likes ...
- They like ...

所以 NP 需要同时保存：

1. 自己在不同格中的形式。
2. 自己的主谓一致信息。

这两个字段在后面的 `PredVPS` 中都会用到。

### C. Det：限定词

```
Det = {s : Str ; n : Number} ;
```

Det 包含两个信息：

- `s`：限定词本身的字符串。
- `n`：限定词对应的单复数。

例如：

```
a cat
the cats
```

其中：

```
a_Det = {s = "a" ; n = Sg}
```

而：

```
aPl_Det = {s = "" ; n = Pl}
```

这里的 `n` 很重要，因为它决定后面的名词使用单数还是复数。

例如：

- a cat
- cats

### D. AP、CN、V、A、N

这些类别直接使用了上一份资源文件中的类型：

```
AP = Adjective ;
CN = Noun ;
V = Verb ;
V2 = Verb2 ;
A = Adjective ;
N = Noun ;
```

这里需要区分抽象语法类别和资源文件中的数据类型。

例如：

- `N` 是 abstract syntax 中的类别。
- `Noun` 是 `MicroResEng.gf` 中定义的数据类型。

```
N = Noun ;
```

意思就是：抽象语法中的 N，在英语具体语法中用 `Noun` 这个 record 类型表示。

## 2.2 lin：定义语法组合规则

如果说 `lincat` 定义了每个类别的数据结构，那么 `lin` 就定义了如何组合这些数据结构。

这里每条规则都对应 abstract syntax 中的一个 function。

### A. UttS 和 UttNP：构造完整表达

```
UttS s = s ;
UttNP np = {s = np.s ! Acc} ;
```

`UttS`：把一个句子转换成一个完整表达（utterance）。

例如：

```
The cat sleeps.
```

这里直接返回已经构造好的 `S`。

`UttNP`：把一个名词短语转换成完整表达。

```
{s = np.s ! Acc}
```

这里使用 `! Acc` 选择 NP 的宾格形式。

例如：

```
him
her
them
```

为什么使用宾格而不是主格？

这是这个简化语法的一个设计选择。它可能假设独立出现的 NP 使用宾格形式，但这并不适用于所有英语表达。例如，单独说 "He!" 通常使用主格。

### B. PredVPS：构造主语 + 动词短语

```
PredVPS np vp = {
  s = np.s ! Nom ++
      vp.verb.s ! agr2vform np.a ++
      vp.compl
} ;
```

这是整个文件中最值得重点理解的函数之一。

它负责把：

- NP（主语）
- VP（动词短语）

组合成一个完整句子。

我们逐步拆解。

第一步：获取主语的主格形式

```
np.s ! Nom
```

例如：

```
he
she
they
```

第二步：根据主语选择动词形式

```
vp.verb.s ! agr2vform np.a
```

这里实际上调用了上一份 `MicroResEng.gf` 中的函数：

```
agr2vform : Agreement -> VForm
```

回忆一下：

```
Agr Sg => PresSg3 ;
Agr Pl => Inf
```

因此：

| 主语   | Agreement | 动词形式    |
| ---- | --------- | ------- |
| he   | Agr Sg    | PresSg3 |
| she  | Agr Sg    | PresSg3 |
| they | Agr Pl    | Inf     |

例如：

```
He walks.
They walk.
```

第三步：添加补足语

```
vp.compl
```

例如：

```
He eats an apple.
```

这里 `an apple` 就是 VP 中保存的 complement。

第四步：使用 `++` 拼接字符串

```
np.s ! Nom ++
vp.verb.s ! agr2vform np.a ++
vp.compl
```

`++` 是 GF 中的字符串拼接操作。

最终得到：

```
He eats an apple
```

可以把整个函数理解为：

PredVPS：主语 + VP → S

NP

`he` + `Agr Sg`

VP

`walk` + 空 complement

S

`He walks`

注意：这里的动词变形是在构造句子的时候才发生的，而不是在构造 VP 的时候发生的。

这就是前面 VP 为什么要保留整个 `Verb` 形态表的原因。

### C. UseV：构造不及物动词短语

```
UseV v = {
  verb = v ;
  compl = [] ;
} ;
```

这里的 `UseV` 接收一个 `V`，也就是不及物动词（intransitive verb）。

例如：

```
sleep
walk
run
```

它们不需要直接宾语。

函数返回：

```
{
  verb = v ;
  compl = [] ;
}
```

这里：

- `verb = v`：保存动词。
- `compl = []`：补足语为空。

例如：

```
walk
```

先被表示成一个 VP，等到和主语组合后，才得到：

```
The boy walks.
```

### D. ComplV2：构造及物动词短语

```
ComplV2 v2 np = {
  verb = v2 ;
  compl = v2.c ++ np.s ! Acc
} ;
```

这里接收：

- `v2`：双价动词（two-place verb）。
- `np`：动词的宾语。

例如：

```
eat an apple
```

这里的 `eat` 是及物动词，`an apple` 是宾语。

先看：

```
v2.c
```

它来自上一份文件：

```
Verb2 : Type = Verb ** {c : Str} ;
```

其中 `c` 用来保存介词。

对于普通及物动词：

```
c = []
```

对于带介词的动词：

```
c = "for"
```

接着：

```
np.s ! Acc
```

选择宾语的宾格形式。

例如：

```
him
her
them
```

因此：

```
compl = v2.c ++ np.s ! Acc
```

可以实现两种情况：

| 动词   | 介词 c | 宾语       | 结果       |
| ---- | ---- | -------- | -------- |
| eat  | 空    | an apple | an apple |
| see  | 空    | him      | him      |
| wait | for  | him      | for him  |

注意这里有一个值得留意的设计：介词和宾语都被放进了 `compl` 字段，而不是单独保存。

### E. UseComp 和 CompAP：系动词结构

```
UseComp comp = {
  verb = be_Verb ;
  compl = comp.s
} ;
```

这里使用 `be_Verb`，把系动词 be 加到 complement 前面。

例如：

```
The boy is happy.
```

其中：

- `be` 是系动词。
- `happy` 是 complement。

而：

```
CompAP ap = ap ;
```

则是把一个形容词短语 AP 转换成 Comp。

例如：

```
happy
```

这里并没有进行字符串拼接，只是直接返回 AP。

两个函数结合起来：

```
CompAP happy
    ↓
UseComp happy
    ↓
VP = {verb = be_Verb ; compl = "happy"}
    ↓
PredVPS theBoy VP
    ↓
The boy is happy
```

这也说明了为什么 `VP` 的设计需要包含 `verb` 和 `compl` 两个字段：既可以处理普通动词，也可以处理 be + complement 的结构。

一个需要注意的限制： 这里的 `be_Verb` 来自上一份文件，目前单复数形式可以通过 `agr2vform` 选择，但 `be_Verb` 本身的 Inf 形式是 `are`。所以如果某个规则需要真正使用 be 的原形，当前实现并不完善。

### F. AdvVP：给动词短语添加副词

```
AdvVP vp adv =
  vp ** {compl = vp.compl ++ adv.s} ;
```

这里使用了：

```
**
```

它是 record combination（record 组合）。

左边：

```
vp
```

是原来的 VP。

右边：

```
{compl = vp.compl ++ adv.s}
```

是一个只包含 `compl` 字段的 record。

组合后，保留原来的 `verb`，同时更新 `compl`。

例如：

```
sleep
```

添加副词：

```
already
```

得到：

```
sleep already
```

之后与主语组合：

```
The boy sleeps already.
```

这里的副词被追加到了 complement 的末尾。

注意：这是一种简化的线性化方式，并没有完整处理英语副词的语序和位置差异。

### G. DetCN：限定词 + 名词

```
DetCN det cn = {
  s = \\c => det.s ++ cn.s ! det.n ;
  a = Agr det.n ;
} ;
```

这是另一个非常重要的函数。

它将：

- Det（限定词）
- CN（名词中心语）

组合成 NP（名词短语）。

例如：

```
a cat
the cats
```

先看：

```
s = \\c => det.s ++ cn.s ! det.n ;
```

这里的 `\\c` 是 GF lambda 表达式的写法。

它表示定义一个函数，接收参数 `c`，然后返回：

```
det.s ++ cn.s ! det.n
```

为什么这里接收 `c`，却没有使用它？

因为这个简化语法中的普通名词不区分主格和宾格。

因此，无论传入：

```
Nom
```

还是：

```
Acc
```

都会返回同一个名词短语。

例如：

```
a cat
```

无论放在主语还是宾语位置，形式都一样。

再看：

```
a = Agr det.n ;
```

这一步非常重要。

它把限定词的 Number 转换成 Agreement，保存到 NP 中。

例如：

```
a_Det = {s = "a" ; n = Sg}
```

经过 `DetCN` 后，得到：

```
{
  s = table {
    Nom => "a cat" ;
    Acc => "a cat"
  } ;
  a = Agr Sg
}
```

因此，后续 `PredVPS` 就知道应该使用第三人称单数动词形式。

### H. UsePron：代词直接作为 NP 使用

```
UsePron p = p ;
```

这里非常简单。

因为 `Pron` 和 `NP` 的 lincat 定义完全相同：

```
NP = {s : Case => Str ; a : Agreement} ;
Pron = {s : Case => Str ; a : Agreement} ;
```

所以可以直接返回。

例如：

```
he
she
they
```

它们已经有了：

- 主格和宾格形式。
- Agreement 信息。

不需要再进行其他转换。

### I. Det 的具体实现

```
a_Det = {
  s = pre {"a"|"e"|"i"|"o" => "an" ; _ => "a"} ;
  n = Sg
} ;
```

这里实现了英语不定冠词 a/an。

`pre` 是 Prelude 中提供的字符串处理操作。

这个表达式根据名词的首字母选择：

- a
- e
- i
- o

如果是这些字母开头，就返回 `an`，否则返回 `a`。

例如：

```
an apple
a cat
```

不过注释也已经指出：

```
--- a/an can get wrong
```

因为英语的 a/an 实际上取决于发音，而不完全取决于拼写。

例如：

- an hour
- a university

这个简单规则无法正确处理它们。

再看：

```
aPl_Det = {s = "" ; n = Pl} ;
```

这里的字符串为空，表示复数名词前不需要不定冠词。

例如：

```
cats
```

接下来：

```
the_Det = {s = "the" ; n = Sg} ;
thePl_Det = {s = "the" ; n = Pl} ;
```

定冠词 the 的单复数形式相同，但 Number 不同。

这使得后面的 `DetCN` 可以正确选择名词的单数或复数形式。

### J. UseN：名词直接转换为 CN

```
UseN n = n ;
```

和 `UsePron` 类似。

这里 `N` 和 `CN` 的 lincat 都是 `Noun`，因此直接返回。

### K. AdjCN：形容词 + 名词

```
AdjCN ap cn = {
  s = table {n => ap.s ++ cn.s ! n}
} ;
```

它将形容词 AP 和名词 CN 组合成一个带形容词修饰的名词短语中心语。

例如：

```
big cat
big cats
```

其中：

```
ap.s
```

是形容词字符串，例如 `"big"`。

而：

```
cn.s ! n
```

根据 Number 选择名词形式。

最终：

```
big ++ cat
big ++ cats
```

得到：

```
big cat
big cats
```

这里的 `n` 是 table 的参数，意味着这个函数保留了名词的单复数变化。

### L. PositA：形容词原级

```
PositA a = a ;
```

这里把形容词 A 转换成 AP。

例如：

```
big
small
beautiful
```

目前没有处理比较级和最高级，只使用形容词原级（positive form）。

### M. PrepNP：介词 + 名词短语

```
PrepNP prep np = {
  s = prep.s ++ np.s ! Acc
} ;
```

这个函数将介词和 NP 组合。

例如：

```
with him
in the house
on the table
```

这里同样使用：

```
np.s ! Acc
```

因为英语介词后面的代词通常使用宾格：

- with him
- with her
- with them

而不是：

- with he
- with she
- with they

### N. 定义具体介词

```
in_Prep = {s = "in"} ;
on_Prep = {s = "on"} ;
with_Prep = {s = "with"} ;
```

这三个函数分别定义了三个介词。

它们都返回相同的数据结构：

```
Prep = {s : Str} ;
```

例如：

```
in_Prep
```

得到：

```
{s = "in"}
```

### O. 定义代词

以 he 为例：

```
he_Pron = {
  s = table {Nom => "he" ; Acc => "him"} ;
  a = Agr Sg ;
} ;
```

这里同时实现了两件事情：

1. 用 table 保存主格和宾格。
2. 用 `Agr Sg` 表示这个代词是单数。

另外两个：

```
she_Pron
they_Pron
```

也是同样的设计。

| Pron | Nom  | Acc  | Agreement |
| ---- | ---- | ---- | --------- |
| he   | he   | him  | Agr Sg    |
| she  | she  | her  | Agr Sg    |
| they | they | them | Agr Pl    |

这样，代词既可以根据句法位置选择形式，又可以控制动词的主谓一致。

# 3. Lexicon part：词汇表

接下来是：

```
---------------------------
-- Lexicon part ----------
---------------------------
```

这里定义具体英语词汇。

例如：

```
lin animal_N = mkN "animal" ;
lin apple_N = mkN "apple" ;
lin baby_N = mkN "baby" ;
lin bad_A = mkA "bad" ;
lin big_A = mkA "big" ;
lin break_V2 = mkV2 (mkV "break" "broke" "broken") ;
```

这里的 `lin` 和前面 Grammar part 中的 `lin` 是同一个关键字。

它们都是在定义抽象语法函数的具体线性化方式。

例如，如果 abstract syntax 中有：

```
fun
  apple_N : N ;
```

那么：

```
lin apple_N = mkN "apple" ;
```

就定义了 `apple_N` 在英语中的具体实现。

## 3.1 词汇命名规则

这里使用了比较常见的 GF 命名方式：

| 后缀     | 词类    | 示例            |
| ------ | ----- | ------------- |
| `_N`   | 名词    | `apple_N`     |
| `_A`   | 形容词   | `big_A`       |
| `_V`   | 不及物动词 | `walk_V`      |
| `_V2`  | 双价动词  | `eat_V2`      |
| `_Adv` | 副词    | `already_Adv` |

这些后缀主要是帮助开发者识别词汇类别。

真正决定它们属于什么类别的，是 abstract syntax 中的类型声明。

## 3.2 规则名词与不规则名词

例如：

```
lin animal_N = mkN "animal" ;
lin apple_N = mkN "apple" ;
lin baby_N = mkN "baby" ;
```

这里调用的是单参数版本的 `mkN`。

它会自动生成名词复数形式。

例如：

| 输入     | 单数     | 复数      |
| ------ | ------ | ------- |
| animal | animal | animals |
| apple  | apple  | apples  |
| baby   | baby   | babies  |

但是对于不规则名词：

```
lin child_N = mkN "child" "children" ;
lin man_N = mkN "man" "men" ;
lin woman_N = mkN "woman" "women" ;
```

这里提供两个参数：

- 第一个参数：单数。
- 第二个参数：复数。

因为这些名词不能简单地通过添加 `s` 得到复数。

另外：

```
lin fish_N = mkN "fish" "fish" ;
```

表示单复数形式相同。

## 3.3 规则动词与不规则动词

例如：

```
lin walk_V = mkV "walk" ;
lin play_V = mkV "play" ;
lin jump_V = mkV "jump" ;
```

这些调用单参数版本的 `mkV`，自动生成动词形式。

例如：

```
walk
walks
walked
walked
walking
```

而不规则动词：

```
lin drink_V2 = mkV2 (mkV "drink" "drank" "drunk") ;
lin eat_V2 = mkV2 (mkV "eat" "ate" "eaten") ;
lin see_V2 = mkV2 (mkV "see" "saw" "seen") ;
```

这里提供三个参数：

1. Infinitive
2. Past
3. Past participle

例如：

```
mkV "drink" "drank" "drunk"
```

其余两种形式（第三人称单数和现在分词）仍然会自动生成。

## 3.4 不及物动词和及物动词

这个区别很重要。

例如：

```
lin sleep_V = mkV "sleep" ;
lin walk_V = mkV "walk" ;
lin run_V = mkV "run" ;
```

这些是不及物动词（intransitive verbs）。

而：

```
lin eat_V2 = ...
lin drink_V2 = ...
lin see_V2 = ...
```

这些是及物动词（transitive verbs）。

它们的区别体现在 abstract syntax 的类型中：

- `V`：动词本身可以构成 VP。
- `V2`：需要一个 NP 作为宾语，才能构成 VP。

例如：

```
The boy sleeps.
```

可以使用 `UseV`。

而：

```
The boy eats an apple.
```

需要使用 `ComplV2`。

## 3.5 特殊的 wait_V2

```
lin wait_V2 = mkV2 "wait" "for" ;
```

这是一个比较有意思的例子。

因为英语中通常说：

```
wait for someone
```

而不是：

```
wait someone
```

所以这里使用双参数版本的 `mkV2`：

- `"wait"`：动词。
- `"for"`：介词。

最终通过前面的 `ComplV2` 组合成：

```
wait for someone
```

注意：这份语法将介词直接放在动词的 complement 字段中，因此可以支持这种结构，但并没有完整建模英语动词的论元结构。

# 4. Paradigms part：词汇构造函数

最后一部分是：

```
oper
  mkN = overload {
    ...
  } ;
```

这一部分和上一份 `MicroResEng.gf` 有密切关系。

前面 Lexicon part 中大量使用了：

```
mkN
mkA
mkV
mkV2
mkAdv
```

这些函数就是在这里定义的。

它们的作用是：把简单的字符串或已有的词汇数据结构转换成 GF 所需要的具体语法类别。

## 4.1 mkN：构造名词

```
mkN = overload {
  mkN : Str -> Noun
    = \n -> lin N (smartNoun n) ;

  mkN : Str -> Str -> Noun
    = \sg,pl -> lin N (mkNoun sg pl) ;
} ;
```

这里有一个重要概念：`overload`。

它允许同一个函数名称对应多个不同的函数定义，只要参数类型不同。

这里有两个版本。

版本一：一个参数

```
mkN "cat"
```

对应：

```
mkN : Str -> Noun
```

内部调用：

```
smartNoun "cat"
```

自动生成：

```
cat / cats
```

版本二：两个参数

```
mkN "child" "children"
```

对应：

```
mkN : Str -> Str -> Noun
```

内部调用：

```
mkNoun "child" "children"
```

直接指定单复数。

这里的：

```
lin N (...)
```

是 GF 的 `lin` 转换操作，用来将资源层面的词汇表示转换成相应的线性化类别。

你可以把它理解为：把构造好的 Noun 数据结构转换成当前具体语法中 `N` 所需要的表示。

## 4.2 mkA：构造形容词

```
mkA : Str -> A
  = \s -> lin A {s = s} ;
```

这个函数比较简单。

接收一个字符串：

```
mkA "beautiful"
```

构造：

```
{s = "beautiful"}
```

然后通过 `lin A` 转换成 A 类别。

因为当前的 `Adjective` 类型只包含一个字符串：

```
Adjective : Type = {s : Str} ;
```

所以暂时不需要考虑形容词的比较级、最高级或其他形态变化。

## 4.3 mkV：构造动词

```
mkV = overload {
  mkV : (inf : Str) -> V
    = \s -> lin V (smartVerb s) ;

  mkV : (inf,pres,part : Str) -> V
    = \inf,pres,part -> lin V (irregVerb inf pres part) ;
} ;
```

这里也有两个版本。

版本一：一个参数

```
mkV "walk"
```

自动调用：

```
smartVerb "walk"
```

生成：

| 形式       | 结果      |
| -------- | ------- |
| Inf      | walk    |
| PresSg3  | walks   |
| Past     | walked  |
| PastPart | walked  |
| PresPart | walking |

版本二：三个参数

```
mkV "drink" "drank" "drunk"
```

调用：

```
irregVerb inf pres part
```

生成：

| 形式       | 结果       |
| -------- | -------- |
| Inf      | drink    |
| PresSg3  | drinks   |
| Past     | drank    |
| PastPart | drunk    |
| PresPart | drinking |

这里要特别注意：虽然参数名称是 `pres`，但实际上第二个参数代表的是过去式（past），而不是 present tense。

因为 `irregVerb` 的定义是：

```
irregVerb : (inf,past,pastpart : Str) -> Verb
```

所以这里的 `pres` 命名容易造成误解，最好将它改成 `past`。

## 4.4 mkV2：构造双价动词

这是整个 Paradigms part 中最复杂的函数。

```
mkV2 = overload {
  mkV2 : Str -> V2
    = \s -> lin V2 (smartVerb s ** {c = []}) ;

  mkV2 : Str -> Str -> V2
    = \s,p -> lin V2 (smartVerb s ** {c = p}) ;

  mkV2 : V -> V2
    = \v -> lin V2 (v ** {c = []}) ;

  mkV2 : V -> Str -> V2
    = \v,p -> lin V2 (v ** {c = p}) ;
} ;
```

这里一共有四个版本。

| 版本 | 输入          | 用途           |
| -- | ----------- | ------------ |
| 1  | `Str`       | 规则及物动词       |
| 2  | `Str + Str` | 带介词的规则动词     |
| 3  | `V`         | 已经构造好的动词     |
| 4  | `V + Str`   | 已构造好的动词 + 介词 |

我们逐个看。

版本一：普通及物动词

```
mkV2 "kill"
```

首先：

```
smartVerb "kill"
```

生成动词形态表。

然后：

```
** {c = []}
```

给它添加一个字段：

```
c = []
```

最后得到一个 `Verb2`。

例如：

```
kill someone
```

版本二：带介词的规则动词

```
mkV2 "wait" "for"
```

生成：

```
smartVerb "wait" ** {c = "for"}
```

因此：

```
wait for someone
```

版本三：接收已经构造好的动词

```
mkV2 (mkV "drink" "drank" "drunk")
```

这里首先：

```
mkV "drink" "drank" "drunk"
```

得到一个 `V`。

然后：

```
v ** {c = []}
```

把它转换成 `V2`。

这种方式很有用，因为不规则动词已经有了完整的形态变化，不需要重新生成。

版本四：已构造好的动词 + 介词

```
mkV2 (mkV "wait") "for"
```

先构造动词，再添加介词字段。

四个版本实际上都是在完成同一件事情：

把 Verb 转换成 Verb2，并根据需要添加介词信息。

## 4.5 mkAdv：构造副词

```
mkAdv : Str -> Adv
  = \s -> lin Adv {s = s} ;
```

例如：

```
mkAdv "already"
```

得到：

```
{s = "already"}
```

然后转换为 Adv 类别。

## 4.6 mkPrep：构造介词

```
mkPrep : Str -> Prep
  = \s -> lin Prep {s = s} ;
```

例如：

```
mkPrep "under"
```

得到：

```
{s = "under"}
```

不过在当前 Lexicon part 中，介词 `in`、`on`、`with` 是直接定义的，并没有调用 `mkPrep`。

# 5. 两个文件如何协作？

这是我认为你最应该掌握的部分。

我们把之前的 `MicroResEng.gf` 和现在的 `MicroLangEng.gf` 放在一起看。

MicroResEng.gf

Resource module

定义底层的数据结构和形态变化规则。

- `Noun`
- `Verb`
- `Adjective`
- `smartNoun`
- `smartVerb`
- `agr2vform`

被 MicroLangEng 导入并使用

MicroLangEng.gf

Concrete syntax

定义英语的词汇、短语和句子如何构造。

- `lincat`
- `lin`
- Lexicon
- Paradigms

实现抽象语法 MicroLang.gf

最终英语表达

- The boy walks.
- The girl eats an apple.
- They drink water.

## 5.1 用一个完整例子理解

假设我们想生成：

```
The boy eats an apple.
```

我们可以把过程拆成五步。

第一步：Lexicon 构造词汇

```
boy_N = mkN "boy" ;
eat_V2 = mkV2 (mkV "eat" "ate" "eaten") ;
apple_N = mkN "apple" ;
the_Det = {s = "the" ; n = Sg} ;
a_Det = {s = "a" ; n = Sg} ;
```

这些定义分别调用 Paradigms 和 Resource 中的函数。

第二步：构造名词短语

```
DetCN the_Det (UseN boy_N)
```

得到：

```
the boy
```

并且保存：

```
a = Agr Sg
```

另一个：

```
DetCN a_Det (UseN apple_N)
```

得到：

```
an apple
```

并保存 `Agr Sg`。

第三步：构造动词短语

```
ComplV2 eat_V2 appleNP
```

得到：

```
eat an apple
```

这里 VP 仍然保留完整的动词形态表。

第四步：构造句子

```
PredVPS boyNP vp
```

系统通过：

```
agr2vform boyNP.a
```

发现主语是 `Agr Sg`，所以选择：

```
PresSg3
```

于是：

```
eats
```

第五步：拼接最终句子

```
The boy + eats + an apple
```

得到：

Final output

The boy eats an apple.

这就是两个文件配合工作的过程。

# 6. 这份文件有哪些值得注意的局限？

如果你之后需要修改或调试这个 GF 项目，下面几个地方值得特别留意。

| 问题             | 原因                             |
| -------------- | ------------------------------ |
| `a/an` 判断不准确   | 根据首字母而不是实际发音判断                 |
| `be_Verb` 不完整  | am/is/are 的变化没有完整实现            |
| 副词位置过于简单       | `AdvVP` 统一将副词追加到 complement 后面 |
| `UttNP` 使用 Acc | 独立名词短语不一定应该使用宾格                |
| `AdjCN` 比较简单   | 不支持形容词比较级和最高级                  |
| 动词时态有限         | 主要考虑原形、第三人称单数、过去式等基本形式         |
| 词汇覆盖有限         | 目前只实现了一部分英语词汇和语法结构             |

还有一个特别值得检查的地方：

```
be_Verb : Verb = mkVerb "are" "is" "was" "been" "being" ;
```

结合：

```
agr2vform : Agreement -> VForm
```

目前单数主语会选择 `PresSg3`，复数主语会选择 `Inf`。

所以：

- He is happy. （正确）
- They are happy. （正确）

但是如果构造：

```
I am happy.
```

当前语法没有办法正确表达，因为它没有区分第一人称单数的 `am`。

这也解释了为什么 `MicroResEng.gf` 中有注释：

```
---s Person to be added
```

开发者原本就知道 Agreement 还需要进一步扩展。

# 7. 最后总结：这份文件最重要的知识点

| 概念                | 你需要理解什么             |
| ----------------- | ------------------- |
| `concrete`        | 实现抽象语法的具体语言         |
| `lincat`          | 定义语法类别对应的数据结构       |
| `lin`             | 定义语法函数如何线性化         |
| `record`          | 保存多个相关字段            |
| `table`           | 根据语法参数选择不同形式        |
| `!`               | 从 table 中查询对应形式     |
| `++`              | 拼接字符串               |
| `**`              | 组合 record           |
| `overload`        | 根据参数类型选择不同版本的函数     |
| `lin N` / `lin V` | 将资源层面的词汇数据转换成具体语法类别 |

我建议你特别记住三个设计：

1. NP 保存 Case 和 Agreement。 这让代词能够根据句法位置改变形式，同时控制动词一致。
2. VP 保存 Verb 和 complement。 这让动词的实际形式可以等到主语确定后再选择。
3. Paradigms 调用 Resource 中的函数。 这避免在词汇表里重复编写每个名词和动词的形态变化规则。

这三个设计基本上就是这份 `MicroLangEng.gf` 的核心。

如果你要恢复之前的 GF 学习，我建议不要急着逐行背诵。可以先尝试自己追踪一个简单句子：

```
They drink water.
```

从 `drink_V2` 开始，追踪它如何经过 `mkV`、`mkV2`、`ComplV2`，最后通过 `PredVPS` 变成完整句子。

只要你能独立追踪这条路径，就说明你已经真正理解了 Resource、Paradigms 和 Concrete Syntax 之间的关系。