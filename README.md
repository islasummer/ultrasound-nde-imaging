# Guide to Understanding the Code

### Overall Summary:
1. User enters parameters and presses start
2. Arduino is initialised with stepper motor and encoder
3. Run the step and loop calculation to determine how many steps the motor must move each time for the specified resolution, and calculate how many times the motor must move this number of steps to cover the total distance (as specified by the user)
4. TiePie is configured in block or stream measurement mode
5. If Block mode is configured then start the oscilloscope, else move on
6. Enter loop that repeats for the number of times the motor must move along the length of the test piece in this resolution
	- motor moves resolution
	- encoder checks if the number of steps moved by the motor is equal to the number that it should have moved by and adjusts accordingly
	-  if in block mode, the 555 timer is triggered
	- if in stream mode run the TiePie_stream Measure code:
			 - this will start the measurement, trigger the 555 Timer, and send 10 chunks to the computer and plot the results
	- this repeats until motor has travelled specified length
7. data is saved, if in block mode then the data is plotted


### guide_gui
- The .m file is the Matlab code and the .fig file is how the GUI will look using Matlab's inbuilt GUIDE feature. For background into GUIDE, see YouTube videos which explain how the handles work, as each object in guide_gui.fig has a unique handle name that can be called and set like a variable.
- When a user enters a value in the fields, the GUI will read in the value using the 'get' function and save it to a variable that can be read by other parts of the Matlab program using 'setappdata' and 'getappdata'.
- The main program only runs when the start button is pressed.
- The reset button reverse the motor by 1cm
- There is also a display window that can be used to display text so that the user knows the progress of the scan. This is done using the 'set' function.
- Some subprograms are called from this main code. All the code could have instead been kept in the guide_gui.m file but this would have been very long so instead the code has been modularised for readability.


### TimerTrigger
- 555 Timer has a negative trigger so this code just generates a single 1 ms pulse to start the timer
- The Arduino could be used directly to trigger the pulser and TiePie instead of the 555 Timer


### Step and loop Calc
- Gets the resolution value that has previously been read in
- Calculates the number of motor steps and loops required for single step mode, and returns this value to guide_gui.m


### TiePie_blockSetup
- This is in segment mode and based off the TiePie examples library.
- Configures the TiePie to record in block mode with data samples as an array of segments of length record length (refer to TiePie documentation for more details)
- Adjust number of samples, segments, sampling frequency, and trigger mode to suit your own preferences


### TiePie_streamSetup
- Configures the TiePie to record in stream measurement mode as in the TiePie examples library.
- Adjust sampling frequency and record length accordingly


### TiePie_blockStart
- starts the oscilloscope which will do nothing until a trigger pulse is received



### TiePie_streamMeasure
- see TiePie Matlab examples library
- Starts the oscilloscope and triggers the 555 timer
- Records data and sends 10 chunks to the computer and then plots in real time
- Because the record length had to be so long, each data set is checked to see if it crosses a threshold of 0.5V (i.e to detect for ultrasound transmit pulse). Once the threshold has been crossed the first 350 samples are ignored (as this is just from the transducer to the top of the test piece and so is not useful) and then the next 200 samples are plotted (calculated as being the number of samples from the top of the test piece to the bottom).
- SSP algorithm is applied to this reduced data set
- Data is added to an array which is saved into a MAT file in the guide_gui.m
- Scope is stopped


### TiePie_streamPlot
- Stream mode is very slow so separate plot code was create to try and increase the refresh rate of graphs
- This code will only run every time the motor loop is divisible by 5 (to increase refresh rate)
-  Applies a bandpass filter to input signal to remove DC drift and plots in real-time
- Plots results after SSP in real-time as A-scan and B-scan


### TiePie_blockMeasure
- Gets data from the scope
- Saves to a MAT file called blockData


### TiePie_blockPlot
- reads in the data file 'blockData' which is saved as a MAT file
- ch1 is odd columns, ch2 is even
- ch1 is an array of segments made up of samples equal to the record length
- channel1 reshapes ch1 to be a single array that can be plotted as an A-scan over the total measurement time
- B-scan needs to be a 2D matrix hence segments are required to plot the data. Can be plotted in colour or in greyscale.


### Real-time SSP
- This is the code for the SSP algorithm used for stream mode so that data can be processed in real-time


### filterBank
- Creates a bank of Gaussian bandpass filters.
- Requires the input parameters based on the type of transducer used and returns a bank of Gaussian bandpass filters as an array in the form of filters x number of samples


### splitBands
-  This function takes in the Gaussian filter bank (in form filters x samples) and part of the input signal (in block mode the data is saved as a number of segments each of length equal to the record length, so this requires that each of the segments are fed individually into this function I.e. the input_spectrum is 1 x record length).
 - Splits the input spectrum by multiplying it with the bank of bandpass filters with y an array of size filters x samples
- Output 'y' is converted to the time domain
- Recombination algorithm is polarity thresholding with absolute minimisation, so for a given moment in time the minimum output of each of the filters is only passed if all the filters have the same polarity. Otherwise the output is zero.
- Function returns the processed input signal


### SSP
- This code calls the functions splitBands and filterBank to post-process the blockData
- data is imported
- The reflection echoes corresponding to the test sample are located and saved in the array sample
- sample data is converted to time domain
- SSP is performed using the values from the transducer data sheet to generate the filter bank. SSP algorithm is only applied to data set corresponding to the test sample.
- Results are plotted as an A-scan and B-scan.