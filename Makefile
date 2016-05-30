all: prospector
	fbc -O 2 src/prospector_nosound.bas -x prospector

clean:
	rm -f prospector
