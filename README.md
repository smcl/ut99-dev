# UT99-dev

This is a collection of things I've played around with in UnrealScript for UT99.

## Usage

Firstly ensure that git is installed, make is installed and that the `ucc.exe` file is in your `PATH` (it's in the UnrealTournament/System dir). Then add the following to your `UnrealTournament.ini` in the `[Editor.EditorEngine]` section:

    EditPackages=SeanMutator
    EditPackages=ProtectSeanMutator
    EditPackages=VampireSeanMutator
    EditPackages=GolemMutator
    EditPackages=TerminatorHud

Then go to the UnrealTournament folder:

    $ cd whatever/path/to/UnrealTournament
    $ git clone https://github.com/smcl/ut99-dev
    $ make

## TODO

- explore HUD Mutators (render simple Game of Life?)
- make exploding kamikaze bot
- I saw "nalicow" model in UnrealShare I think, can we have that little guy running around? (edit: it's mentioned in the unrealscript source dump but the models, textures and sounds aren't in the standard game)


## Notes

Getting the screen resolution involves a `Canvas`'s `SizeX` and `SizeY` properties.

Getting the FOV can be done by finding the current playerpawn and accessing `DefaultFOV`


