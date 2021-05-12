# GolemMutator

Whenever player "sean" is harmed, spawn a super-strength, stacked beast of a bot who seeks me out and protects me.

    $ rm -f ../System/GolemMutator.* && ucc make && cp GolemMutator.int ../System/

## TODO:

- choose a suitable model + skin
- announce on entering the arena
- keep prioritizing bots that attack "sean" (stack? or just set `Bot.Enemy`?)
- remove the dependency on `BotConfig` - we can handle this ourselves
- GetSean() into some common code both can Bot+Mutator can use (+ generic?)