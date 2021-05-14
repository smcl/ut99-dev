# GolemMutator

Whenever player "sean" is harmed, spawn a super-strength, stacked beast of a bot who seeks me out and protects me.

    $ rm -f ../System/GolemMutator.* && ucc make && cp GolemMutator.int ../System/

## TODO:

- announce self on entering the arena
- keep prioritizing bots that attack "sean" (stack? or just set `Bot.Enemy`?)
- `GolemBot` should subclass `FemaleBotPlus` (or even just `Bot`) instead of `TFemale2Bot` to allow more customization
- deep dive into the various AI `state` blocks