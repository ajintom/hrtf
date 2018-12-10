# hrtf
## An Auralization Framework for Virtual Acoustics:

This project aims to build a structural model for binaural sound synthesis followed by investigating aurlaization and stereo-to-binaural upmixing techniques using time-domain (acoustics modelling) as well as frequency-domain (signal processing) approaches.

The main source files are [/binauralModel/model.m] for the analytical model for binaural sound synthesis and [/binRIR/binRIR.m] for binauralization of room impulse responses.

Dependencies include: [github.com/AudioGroupCologne/SOFiA]

For HRTF and HRIR plots run /binauralModel/run_*.m


Project report available at [ajintom.com/618/]






WIP: The binaural model is implemented as a VST plugin [/binJUCE/Builds/MacOSX/build/Debug/binJUCE.app/Contents/MacOS/binJUCE] using JUCE [juce.com].
