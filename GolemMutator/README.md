# GolemMutator

Whenever player "sean" is harmed, spawn a super-strength, stacked beast of a bot who seeks me out and protects me.

    $ rm -f ../System/GolemMutator.* && ucc make && cp GolemMutator.int ../System/

## TODO:

- announce self on entering the arena
- keep prioritizing bots that attack "sean" (stack? or just set `Bot.Enemy`?)
- GetSean() into some common code both can Bot+Mutator can use (+ generic?)
- `GolemBot` should subclass `FemaleBot` (or even just `Bot`) instead of `FemaleBotPlus`