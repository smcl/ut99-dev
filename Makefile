all: copy_packages

clean:
	rm -f System/GolemMutator.*
	rm -f System/GolemMutator.*
	rm -f System/ProtectSeanMutator.*
	rm -f System/SeanMutator.*
	rm -f System/VampireSeanMutator.*
	rm -f System/StubHud.*
	rm -f System/TerminatorHud.*

ucc_make: clean
	ucc make

copy_packages: ucc_make
	cp GolemMutator/GolemMutator.int System/
	cp ProtectSeanMutator/ProtectSeanMutator.int System/
	cp SeanMutator/SeanMutator.int System/
	cp VampireSeanMutator/VampireSeanMutator.int System/
	cp StubHud/StubHud.int System/
	cp TerminatorHud/TerminatorHud.int System/
