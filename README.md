# MIDI-64nicator
A tool to automatically format MIDIs for Doom 64 EX which are also compatible with ports such as Doom 64 Remaster, Retribution, and DZDoom.

## Installation
The program runs on Windows 64 and is programmed in MATLAB using its app designer. Run the MIDI 64nicator executable in this directory. When running the executable it will require a 700 mb download, an unfortunate part of MATLAB compiled programs. After installation it can be found in the Start Menu or via the Search Bar as "MIDI64nicator".

## Instructions
First, you will need to compose a midi using the Doom 64 soundfont which can be generated with Doom 64 EX, or found in Doom 64 Retribution, DZDoom, and the Doom 64 Remaster (DLS format) program folders. Once your midi is ready, run MIDI 64nicator. The necessary processing options will be checked by default, and click on "Convert" to load your midi. Find and select your midi, the conversion process will happen automatically. When the process is over, it will open a dialog to save the file. That file should now be ready to go in your favorite Doom 64 port! Some of the optional processing options may help with compatibility.

## Parameter Descriptions
Swap Note Offs - Doom 64 EX does not properly execute note off events (128 to 143) and instead recognizes note on events with a velocity of 0 to silence notes. This option will convert these note off events appropriately.

Insert Loop Times - Doom 64 has a special event (127) which determines on how the music loops, without this the tracks won't play properly. This option will strip any existing loops for each track (if needed) and will these events at the beginning and end of tracks.

Strip Info Events - Extra info events (1 to 4) will cause tracks not to play in Doom 64 EX. This option will remove them.

Zero Run Mode - Midi events have two running modes, 0 and 1. Events with mode 1 wont be recognized in Doom 64 EX, thus this option will change them to 0.

Add Tempo - Doom 64 EX requires a tempo event (81) for tracks to be played. If it is not defined this option will add a default tempo.

Re-Channel - This option makes sure all notes are assigned to the proper channel and the channels are re-organized sequentially. This reduces many MIDI play back bugs.

Truncate End - This option moves the track end and also the Doom 64 loop point to the last midi event which can eliminate silence after a track.

Non-Looping - This option removes the ending Doom 64 loop point which prevents the track from looping in Doom 64 EX. This is important for the title track of the game.

## Known Issues
If you want to edit the original Doom 64 midis, use a program like Aria Maestosa to convert it to a standard midi format. Programs like Sekaiju seem to cause conversion issues in MIDI 64nicator. However once midis are in standard midi format, editing them with Sekaiju seems to be fine.

This applies to midi playback on Doom 64 EX. Tracks with very short note and controller events can have tracks which eventually go out of sync. Perhaps the resolution of the midi is too high. If you experience this, try using longer notes or have controller events with more space between them.

## Helpful Software
Midi Composition:
Aria Maestosa - http://ariamaestosa.sourceforge.net/

Sekaiju - https://openmidiproject.osdn.jp/index_en.html

SynthFont - http://www.synthfont.com/

Soundfont Handling:
Polyphone - https://www.polyphone-soundfonts.com/
Virtual MIDI Synth - https://coolsoft.altervista.org/en/virtualmidisynth

MIDI Decoding:
Ken Schutte's MATLAB Scripts - https://kenschutte.com/midi
MIDIopsy - https://jeffbourdier.github.io/midiopsy/

## Credits
Conversion Coding: Immorpher (https://www.youtube.com/c/Immorpher)
D64 MIDI Decoding: Impboy, Anomalous Horse
MIDI In/Out: Ken Schutte (https://kenschutte.com/midi)
Doom 64 Discord: https://discord.gg/Ktxz8nz
