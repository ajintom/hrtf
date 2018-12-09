/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"


//==============================================================================
IDelayAudioProcessorEditor::IDelayAudioProcessorEditor (IDelayAudioProcessor& p)
    : AudioProcessorEditor (&p), processor (p)
{
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize (400, 300);
    
    azSlider.setRange (-90,90);
    azSlider.setTextBoxStyle (Slider::TextBoxRight, false, 100, 20);
    azSlider.addListener(this);
    azLabel.setText ("Azimuth", dontSendNotification);
    
    addAndMakeVisible (azSlider);
    addAndMakeVisible (azLabel);

    
    elSlider.setRange (-90,90);
    elSlider.setTextBoxStyle (Slider::TextBoxRight, false, 100, 20);
    elSlider.addListener(this);
    elLabel.setText ("Elevation", dontSendNotification);
    
    addAndMakeVisible (elSlider);
    addAndMakeVisible (elLabel);
    
    
    
}

IDelayAudioProcessorEditor::~IDelayAudioProcessorEditor()
{
}

//==============================================================================
void IDelayAudioProcessorEditor::paint (Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));

    g.setColour (Colours::white);
    g.setFont (15.0f);
    g.drawFittedText ("HS_filter and Torso-Shoulder echoes active", getLocalBounds(), Justification::centred, 1);
    
}

void IDelayAudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
    
    azLabel.setBounds (10, 10, 90, 20);
    azSlider.setBounds (100, 10, getWidth() - 110, 20);
    elLabel.setBounds (10, 50, 90, 20);
    elSlider.setBounds (100, 50, getWidth() - 110, 20);


}

void IDelayAudioProcessorEditor::sliderValueChanged(Slider* slider)
{
    if (slider == &azSlider)
        processor.set_az(azSlider.getValue());
    else if (slider == &elSlider)
        processor.set_el(elSlider.getValue());


    
}
