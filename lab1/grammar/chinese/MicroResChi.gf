
-- Chinese Resource Module
-- This module defines the basic data types and operations
-- used in the Chinese concrete syntax.

resource MicroResChi = open Prelude in {

  -- PARAMETERS
  -- Define grammatical features used by the Chinese grammar.

  param

    -- Number: distinguishes singular and plural.
    -- Chinese nouns do not change form according to number,
    -- but this distinction is retained for grammatical compatibility.
    Number = Sg | Pl ;

  -- OPERATIONS
  -- Define the data types and constructors used in the grammar.

  -- Noun: represents a Chinese noun.
  -- The field s stores its surface form as a string.
  -- No number-based inflection is needed in this simplified grammar.
  oper
    Noun : Type = {s : Str};

    -- mkNoun: constructs a Noun from a string.
    -- Input: a word (Str)
    -- Output: a Noun record containing that word.
    mkNoun : Str -> Noun = \word -> {
      s = word
    } ;


    -- Adjective: represents a Chinese adjective.
    -- The field s stores the adjective's surface form.
    Adjective : Type = {s : Str} ;


    -- Verb: represents a Chinese verb.
    -- The field s stores the verb's surface form.
    -- Verbs do not have tense or person inflection in this simplified grammar.
    Verb : Type = {s : Str};

    -- mkVerb: constructs a Verb from a string.
    -- Input: a word (Str)
    -- Output: a Verb record containing that word.
    mkVerb : Str -> Verb = \word -> {
      s = word
    } ;


    -- Verb2: represents a two-place (transitive) verb.
    -- It combines the basic Verb record with an additional field c.
    -- s = the verb form
    -- c = an optional preposition or connecting element before its object.
    -- For verbs that take a direct object, c can be an empty string.
    Verb2 : Type = Verb ** {c : Str} ;

}
