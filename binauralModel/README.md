# HRTF Structural Model

WIP: In the context of headphone listening, 3D localization can be achieved using head-related transfer function (HRTF). The aim of this project is to build a structual model to synthesize binaural sound from monaural sound. The model is based on a simplified time-domain description of the physics of wave propagation and diffraction. 


Apart from Interaural Time DIfference (ITD) and Interaural Level Difference (ILD), there are three other cues that come into play while localizaing sound objects in space. Localization of a sound source in relation to azimuth and elevation are accomplished by accounting for reflections off of the shoulders and upper torso, the acoustical shadowing effect of the head, and the reflections due to the small ridges in the outer ear (called the pinna). These three effects can be modeled on the digital representation of the source signal.
Modeling the structural properties of the system pinna-head-torso gives us the possibility of applying continuous variation to the positions of sound sources and to the morphology of the listener. Much of the physical/geometric properties can be understood by careful analysis of the HRIRs, plotted as surfaces, functions of the variables time and azimuth, or time and elevation.

This directory includes implementations of filters and fractional delay-lines used to model the following sub-models:

1. Head-shadow filtering and ITD
2. Shoulder echo and Torso effects 
3. Pinna Reflections 
