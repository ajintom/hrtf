/*
 ==============================================================================
 
 This file was auto-generated!
 
 It contains the basic framework code for a JUCE plugin processor.
 
 ==============================================================================
 */

#include "PluginProcessor.h"
#include "PluginEditor.h"
# define pi 3.14159265358979323846


float coef[6];
float* filter(float az,float el, double fs){
    
    az = az + 90;    // for ease of thought process
    int w0 = 4175; // speed of sound / radius of head
    float alpha = 1.05 + 0.95*cos( (az/150) * pi); // parameters adapted from model fine tuned in MATLAB
    float gd;
    // filter coefficients
    coef[1]  = (alpha + w0/fs) / (1 + w0/fs);
    coef[2]   = (-1*alpha + w0/fs) / (1 + w0/fs);
    
    coef[3] = 1;
    coef[4] = -1 * (1 - w0/fs) / (1 + w0/fs);
    
    if (abs(az) < 90){
        gd  = - fs/w0 * (cos(az * pi/180) - 1) ;
    }
    else{
        gd  = fs/w0 * ((abs(az) - 90) * pi/180 + 1);
    }
    coef[0] = (1-gd)/(1+gd);
    
    
    coef[5] = (fs/1000) * 1.2*(180 - az)/180 * (1 - 0.00004*((el - 80)*180/(180 + az)) * ((el - 80)*180/(180 + az)) );
    
    return coef;
    
    
    
    // head-shadow filter
    //    for (int i = 1; i < numSamples; ++i)
    //        samples[i] = b1 * samples[i] + b2 * samples[(i-1)];// - a2 * samples[(i-1) ];
    //
    // all-pass filter
    //    b1 = gd; b2 = 1; a2 = gd;
    //    for (int i = 1; i < numSamples; ++i)
    //        samples[i] = b1 * samples[i] + b2 * samples[(i-1) ] - a2 * samples[(i-1) ];
    //
    
}



//==============================================================================
IDelayAudioProcessor::IDelayAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
: AudioProcessor (BusesProperties()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
                  .withInput  ("Input",  AudioChannelSet::stereo(), true)
#endif
                  .withOutput ("Output", AudioChannelSet::stereo(), true)
#endif
                  )
#endif
{
}

IDelayAudioProcessor::~IDelayAudioProcessor()
{
}

//==============================================================================
const String IDelayAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool IDelayAudioProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
    return true;
#else
    return false;
#endif
}

bool IDelayAudioProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
    return true;
#else
    return false;
#endif
}

bool IDelayAudioProcessor::isMidiEffect() const
{
#if JucePlugin_IsMidiEffect
    return true;
#else
    return false;
#endif
}

double IDelayAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int IDelayAudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
    // so this should be at least 1, even if you're not really implementing programs.
}

int IDelayAudioProcessor::getCurrentProgram()
{
    return 0;
}

void IDelayAudioProcessor::setCurrentProgram (int index)
{
}

const String IDelayAudioProcessor::getProgramName (int index)
{
    return {};
}

void IDelayAudioProcessor::changeProgramName (int index, const String& newName)
{
}

//==============================================================================
void IDelayAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
    
    
    dbuf.setSize(getNumOutputChannels(),  100000);
    dbuf.clear();
    
    dw = 1;
    dr = 1;
    drp = 0;
    ds = 50000;
    tempL = 0.0;tempR = 0.0;
    fs = sampleRate;
    az = 1;

}

void IDelayAudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool IDelayAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
#if JucePlugin_IsMidiEffect
    ignoreUnused (layouts);
    return true;
#else
    // This is the place where you check if the layout is supported.
    // In this template code we only support mono or stereo.
    if (layouts.getMainOutputChannelSet() != AudioChannelSet::mono()
        && layouts.getMainOutputChannelSet() != AudioChannelSet::stereo())
        return false;
    
    // This checks if the input layout matches the output layout
#if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
#endif
    
    return true;
#endif
}
#endif

void IDelayAudioProcessor::processBlock (AudioSampleBuffer& buffer, MidiBuffer& midiMessages)
{
    ScopedNoDenormals noDenormals;
    const int totalNumInputChannels  = getTotalNumInputChannels();
    const int totalNumOutputChannels = getTotalNumOutputChannels();
    
    for (int i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());
    
    // This is the place where you'd normally do the guts of your plugin's
    // audio processing...
    
    int numSamples = buffer.getNumSamples();
    float az_now = az;
    float el_now = 1.0;
    float l = (az + 90)/180;

    
    
    float* channelDataL = buffer.getWritePointer(0);
    float* channelDataR = buffer.getWritePointer(1);
    
    //
    float* cL =  filter(az_now,el_now,fs);
    float b1_L = cL[1], b2_L = cL[2], a2_L = cL[4],tsL = cL[5];
    float* cR =  filter(-1*az_now,el_now,fs);
    float b1_R = cR[1], b2_R = cR[2], a2_R = cR[4], tsR = cL[5];
   
    //
 
    
    for (int i = 0; i < numSamples; ++i)
    {
        // input buffer to delayline
        dbuf.setSample(0, dw, channelDataL[i]);
        // delay-line to output buffer
        channelDataL[i]= (b1_L * dbuf.getSample(0, dr) + b2_L* dbuf.getSample(0, drp) - a2_L * tempL); //filter equation in time-domain
        tempL = channelDataL[i];
        
        dbuf.setSample(1, dw, channelDataR[i]);
        channelDataR[i]= (b1_R * dbuf.getSample(1, dr) + b2_R* dbuf.getSample(1, drp) - a2_R * tempR);
        tempR = channelDataR[i];
        
        dw = (dw + 1 ) % ds ;
        dr = (dr + 1 ) % ds;
        drp = (drp + 1 ) % ds;
        
    }
    
    
}

//==============================================================================
bool IDelayAudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

AudioProcessorEditor* IDelayAudioProcessor::createEditor()
{
    return new IDelayAudioProcessorEditor (*this);
}

//==============================================================================
void IDelayAudioProcessor::getStateInformation (MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void IDelayAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}



void IDelayAudioProcessor::set_el(float val)
{
    el = val;
}

void IDelayAudioProcessor::set_az(float val)
{
    az = val;
}





//==============================================================================
// This creates new instances of the plugin..
AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new IDelayAudioProcessor();
}
