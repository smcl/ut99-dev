# GolemMutator

Whenever player "sean" is harmed, spawn a super-strength, stacked beast of a bot who seeks me out and protects me.

    $ rm -f ../System/GolemMutator.* && ucc make && cp GolemMutator.int ../System/

## TODO:

- try to spawn close to "sean" (`FindPlayerStart()` is copy-pasted from `BotPack.Bot` and modified to work ... but it is ugly as sin and doesn't do what I want)
- choose a suitable model + skin
- announce on entering the arena
- keep prioritizing bots that attack "sean" (stack? or just set `Bot.Enemy`?)
- remove the dependency on `BotConfig` - we can handle this ourselves