# Asymptotic speedup of ud2gf
The old code tries to apply every possible abstract gf function to every possible combination af GF trees it has found so far, removes any duplicate trees it has found, and iterates this until it can no longer find any new trees.

This is needlessly slow for two reasons:

## First issue
Since we keep the old trees around, we will keep creating the same trees over and over again for each iteration.

For example:
1. If we start with the word `[small_A]`
2. We can apply `PositA` to this and now we have these trees:  `[PositA small_A, small_A]`
3. We can now apply `CompAP` to the first tree and `PositA` to the second tree. This generates these "new" trees: `[CompAP (PositA small_A), PositA small_A]`
4. However, we already had `Posit smallA` from the previous iteration, so now need to remove deduplicate the list of trees, resulting in: `[CompAP (PositA small_A), PositA small_A, small_A]`
5. Now we can apply functions to each of these, and end up with three new trees, only one of which is actually new.

This results in `O(T*F*CT1*CTn)` per iteration, where `T` is the current number of trees, `CT1` is the nuber of possible trees for the first dependent and `F` is the number of abstract functions available. The nuber of iterations should correspond to the maximum depth of the final trees.

### Solution

To solve this issue, all we need to do is to only build on top of *new* trees, since applying functions to the old trees will only produce trees we have already seen, so that work is always redundant.

## Second issue

We have now removed most duplicate work related to the head of the devtree, but it still generates a lot of duplicate trees. The reason for this is that before trying to match against a function, all possible combinations of head tree and dependent trees were calculated, even if the function in question would only take one or two arguments.

### Solution

Instead of first expanding all the possible combinations of GF trees, we keep the tree-shape of the devtree and for each function we first choose a valid head tree and then only decide on as many dependent trees as needed by the function, and only if it managed to create find valid trees for the previous arguments. This can be solved neatly with a list-comprehension.

## Deduplication

Now, since we no longer produce duplicates, we can remove the deduplication code. This has however not yet been done, out of my cowardice.

There is however still one way to produce duplicates: If the initial `PGF.parse` on the idividual words generated multiple trees, where one is a subtree of another, we may generate one the larger tree again.

One idea that might solve this issue, and might also provide other advantages, is to use morphoanalyze instead of parse, so we only get lexical or syncategorematic entries. That would however require reworking the algorithm a bit more.

# Performance

### With both fixes

With these changes upto12eng.conlu takes 17.5 seconds for ud2gf on my machine:

```
$ stack run gf-ud ud2gf grammars/ShallowParse Eng Text -- +RTS -s  < upto12eng.conllu
...

   8,316,725,552 bytes allocated in the heap
  15,835,906,496 bytes copied during GC
     222,330,424 bytes maximum residency (36 sample(s))
       3,737,472 bytes maximum slop
             212 MB total memory in use (0 MB lost due to fragmentation)

                                     Tot time (elapsed)  Avg pause  Max pause
  Gen  0      7855 colls,     0 par    8.971s   9.107s     0.0012s    0.0037s
  Gen  1        36 colls,     0 par    5.383s   5.702s     0.1584s    0.2869s

  INIT    time    0.000s  (  0.004s elapsed)
  MUT     time    3.299s  (  3.360s elapsed)
  GC      time   14.354s  ( 14.809s elapsed)
  EXIT    time    0.000s  (  0.008s elapsed)
  Total   time   17.654s  ( 18.182s elapsed)

  %GC     time       0.0%  (0.0% elapsed)
```

### With only one fix

With only the first half of this change, it takes around 15-30 *minutes* to complete:

```
$ stack run gf-ud ud2gf grammars/ShallowParse Eng Text -- +RTS -s  < upto12eng.conllu
...

1,065,219,555,280 bytes allocated in the heap
  27,001,240,040 bytes copied during GC
     350,466,472 bytes maximum residency (59 sample(s))
       4,709,976 bytes maximum slop
             334 MB total memory in use (0 MB lost due to fragmentation)

                                     Tot time (elapsed)  Avg pause  Max pause
  Gen  0     1020317 colls,     0 par   36.792s  39.373s     0.0000s    0.0307s
  Gen  1        59 colls,     0 par   18.062s  19.380s     0.3285s    1.1113s

  INIT    time    0.000s  (  0.004s elapsed)
  MUT     time  1012.890s  (7124.381s elapsed)
  GC      time   54.855s  ( 58.753s elapsed)
  EXIT    time    0.000s  (  0.003s elapsed)
  Total   time  1067.745s  (7183.142s elapsed)
```

### Original performance

With neither of the optimizations, it takes longer than I am willing to wait.

# Expand the capabilities of macros
With this, you can write tiny programs in macros, for example to change the shape of a tree between GF and ud.

For example, this code allows ud2gf to handle phrases like "small, fluffy and cute":

```haskell
#auxcat Comma PUNCT
#auxfun CommaAP_ ap comma : AP -> Comma -> APComma =  ap ; head punct


-- -- #auxfun AndCutePatternMatch_ and cute : Conj -> AP -> AP2AP = MkAP2AP and cute ; cc head
#auxfun AndCuteCont_ and cute : Conj -> AP -> Pair_Conj_AP = MkPair_ and cute ; cc head

-- #auxfun AP2_ small (MkAP2AP and cute) : AP -> AP2AP -> AP = ConjAP and (BaseAP small cute)) ; head conj
#auxfun AP2_ small andCute : AP -> Pair_Conj_AP -> AP = UsePair_ (AP2_helper_ small) andCute ; head conj
#auxfun AP2_helper_ small and cute :  AP -> Conj -> AP -> AP = ConjAP and (BaseAP small cute) ; head dummy nonexsistent

-- #auxfun APBaseComma_ small fluffy (MkAP2AP and cute)  : AP -> APComma -> AP2AP -> ConjListAP = ConjConsAP and small (BaseAP fluffy cute) ; head conj conj
#auxfun APBaseComma_ small fluffy andCute : AP -> APComma -> Pair_Conj_AP -> ConjListAP = UsePair_ (APBaseComma_helper_ small fluffy) andCute ; head conj conj
#auxfun APBaseComma_helper_ small fluffy and cute : AP -> APComma -> Conj -> AP -> ConjListAP = MkTriple_ and small (BaseAP fluffy cute) ; head dummy dummy

-- #auxfun ConjListToAP2_ (ConjConsAP and small furryFluffyCute) : ConjListAP -> AP = ConjAP and (ConsAP small furryFluffyCute) ; head
#auxfun ConjListToAP2_ and_small_furryFluffyCute : ConjListAP -> AP = UseTriple_ ConjListToAP2_helper_ and_small_furryFluffyCute ; head
#auxfun ConjListToAP2_helper_ and small furryFluffyCute : Conj -> AP -> ListAP -> AP = ConjAP and (ConsAP small furryFluffyCute) ; notreal head dummy

-- #auxfun APAddComma_ furry (ConjConsAP and small fluffyAndCute)  : APComma -> ConjListAP -> ConjListAP = ConjConsAP and small (ConsAP furry fluffyAndCute) ; conj head
#auxfun APAddComma_ furry and_small_fluffyCute  : APComma -> ConjListAP -> ConjListAP = UseTriple_ (APAddComma_helper_ furry) and_small_fluffyCute ; conj head
#auxfun APAddComma_helper_ furry and small fluffyCute : APComma -> Conj -> AP -> ListAP -> ConjListAP = MkTriple_ and small (ConsAP furry fluffyCute) ; dummy head

-- Only used inside other macros
-- Pair_a_b = (a -> b -> r) -> r
#auxfun MkPair_ a b handler : a -> b -> ab2r -> r = handler a b ; head dummy nonexsistent
#auxfun UsePair_ handler pair : ab2r -> Pair_a_b -> r = pair handler ; head dummy
-- Triple_a_b_c = (a -> b -> r) -> r
#auxfun MkTriple_ a b c handler : a -> b -> c -> abc2r -> r = handler a b c ; head dummy nonexsistent nope
#auxfun UseTriple_ handler triple : abc2r -> Triple_a_b_c -> r = triple handler ; head dummy

```

This is pretty hacky though, since some of the macros aren't really real macros, but are only used inside other macros during macro expansion, so it would be nice to have a cleaner solution where you aren't forced to write dummy labels and types.
