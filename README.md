# UT99-dev

This is a collection of things I've played around with in UnrealScript for UT99.

## Usage

Firstly ensure that git is installed, make is installed and that the `ucc.exe` file is in your `PATH` (it's in the UnrealTournament/System dir). Then add the following to your `UnrealTournament.ini` in the `[Editor.EditorEngine]` section:

	EditPackages=SeanMutator
	EditPackages=ProtectSeanMutator
	EditPackages=VampireSeanMutator
	EditPackages=GolemMutator

Then go to the UnrealTournament folder:

    $ cd whatever/path/to/UnrealTournament
    $ git clone https://github.com/smcl/ut99-dev
    $ make

## TODO

- make exploding kamikaze bot
- explore HUD Mutators (render simple Game of Life?)
- I saw "nalicow" model in UnrealShare I think, can we have that little guy running around?