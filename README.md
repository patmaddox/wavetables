# Wavetables

Software for making wavetable audio files for use in UVI Falcon.

## Dependencies

* [Composers Desktop Project](http://www.unstablesound.net/cdp.html)

## Mode 1: Choose your own files to interpolate

Run `ruby wavetables.rb file1.wav file2.wav` to create a wavetable interpolating
between the two files.

## Mode 2: Randomly select waveforms from a directory

Run `random=~/path/to/samples/dir ruby wavetables.rb outname` to create a
wavetable interpolating between two samples randomly selected from the source
directory.

## Good source material

[Adventure Kid Waveforms](http://www.adventurekid.se/akrt/waveforms/adventure-kid-waveforms/)
single cycle waveforms.

## TODO

* Support more than 2 waveforms to be interpolated
* Try it with longer waveforms
* Create wavetables using spectral morphing instead of crossfading interpolation
