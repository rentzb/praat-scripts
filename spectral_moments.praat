#####################################################
# Script by Bradley Rentz
#This script is modified from one made by Earl K. Brown found at http://www-personal.ksu.edu/~ekbrown/scripts/Script_Praat_dur_cog_voic_S.txt
#####################################################
#This Praat script measures duration, center of gravity, standard deviation, skewness, and kurtosis for segments marked on an interval tier
#It generates two .csv files: one with center of gravity and skewness measured at middle 20% of intervals [40%-60%] (output_file_s$),
#the other with center of gravity, sd, skewness, and kurtosis at 10% intervals (output_file_cog_ten$)
#This script was last edited by Bradley Rentz on Jan 14, 2017.
#This script was made on Praat version 5.4.18 for Mac OS X
#Script file has encoding UTF-8
#####################################################
# NOTE:
# Before running this script, you need to make sure the WAV files
# and their corresponding TextGrid files have the same names, 
# including capitalization
# It also assumes the selected tier for the fricatives is an interval tier 
#####################################
#Creates a form asking folders where sound and TextGrid files are saved
# Also asks output file names and for skewness power and center of gravity power for the Praat calculations
# Gets frequencies for Hann band pass filter too
form Info for COG and Skewness Script
comment Where are your files saved?
sentence input_sound_folder /Users/brad_rentz/Desktop/ling632/praat_scripts/presentation/script3/
sentence input_textgrid_folder /Users/brad_rentz/Desktop/ling632/praat_scripts/presentation/script3/
comment What tier number are the fricatives located at?
positive tiernumber 1
comment Note: Output files will be saved in same directory as where this script is saved.
sentence output_file_s data_fricatives.csv
sentence output_file_cog_ten data_fricatives_ten.csv
comment Enter the power for the skewness and center of gravity calculations
positive power_cog 2/3
positive power_sdev 2/3
positive power_skew 2/3
positive power_kurt 2/3
comment Enter info for Hann band pass filter
positive startfreq 750
positive endfreq 11025
positive smoothingfreq 100
endform


# creates headings for the columns and saves them in the s output file (headings tab separated)
headings$ = "FILE'tab$'STRING'tab$'START'tab$'END'tab$'DUR'tab$'COG_MID'tab$'SDEV_MID'tab$'SKEW_MID'tab$KURT_MID"
...+newline$
headings$ > 'output_file_s$'


# creates headings in the file with cog at every 10% mark (tab separated)
headings$ = "FILE'tab$'STRING'tab$'TIME'tab$'PERC'tab$'COG'tab$'SDEV'tab$'SKEW'tab$'KURT"
...+newline$
headings$ > 'output_file_cog_ten$'

#####################################

clearinfo

# gets the names of the textgrids and how many there are
Create Strings as file list...  textgrid_list 'input_textgrid_folder$'*.TextGrid
num_textgrids = Get number of strings

# sets textgrid counter to zero
nr_completed = 0

# loop over the textgrid files
for i to num_textgrids

	# (re)select the textgrid list
	select Strings textgrid_list

	# gets the name of the current textgrid file
	grid_name$ = Get string... i

	# reads the textgrid into the Objects window
	Read from file... 'input_textgrid_folder$''grid_name$'
	cur_grid = selected ("TextGrid")

	# gets basename of the current file (name without extension)
	base_name$ = selected$ ("TextGrid")

	# prints progress report
	printline Working on 'base_name$'... 

	# puts the "wav" extension in a variable
	ext1$ = ".wav"

	# creates sound file pathway
	sound_file_name$ = input_sound_folder$+base_name$+ext1$

	# tests whether the sound file can be read into Praat
	if fileReadable (sound_file_name$)

		# reads in audio file (opens as long sound file to save on memory)
		Open long sound file... 'sound_file_name$'
		sound_one = selected("LongSound")

		# selects the selected long sound
		select 'sound_one'
		# also selects the matching TextGrid
		plus 'cur_grid'
		#open the editor window
		View & Edit

		
		#############################################
		# Selects frication tier from previously defined tier number in initial form
		
		select cur_grid
		#gets tier number from previously defined tier in initial form
		cur_tier_num = tiernumber
		num_intervals = Get number of intervals... 'cur_tier_num'
		# print out which tier it is working on
		printline 'tab$'Working on tier 'cur_tier_num', the frication tier...

		#Loop takes measurements for all intervals of interval tier
		for j from 1 to 'num_intervals'

			select TextGrid 'base_name$'
			interval_name$ = Get label of interval... 'cur_tier_num' j
			
			# Takes the measurments if interval is non-null
			if interval_name$ != ""

				# progress report
				#printline 'tab$''tab$''interval_name$'

				####################
				# gets duration of fricatives that are labels
				# gets duration by finding onset time and offset time and subtracting them
				s_onset = Get starting point... 'cur_tier_num' 'j'
				s_offset = Get end point... 'cur_tier_num' 'j'
				s_dur = 's_offset' - 's_onset'

				####################
				# gets center of gravity and skewness for middle 20% (from 40% to 60%) of fricative interval
				
				#Gets 1/10 of segment duration
				tenth_of_s = s_dur/10
				select LongSound 'base_name$'
				#Defines 40% duration
				start_span = 's_onset'+('tenth_of_s'*4)
				#Defines 60% duration
				end_span = 's_onset'+('tenth_of_s'*6)
				Extract part... start_span end_span yes
				part_name = selected("Sound")
				select 'part_name'

				#Apply Hann band pass filter using variables from initial form (defaults are starting at 750Hz to 11,025Hz with 100Hz smoothing). This 
				Filter (pass Hann band)... startfreq endfreq smoothingfreq
				To Spectrum... Fast
				spectrum = selected("Spectrum")
				select 'spectrum'

				#Measures center of gravity and skewness at midpoint using power variables defined in form at start
				cog_mid = Get centre of gravity... power_cog
				skew_mid = Get skewness... power_skew
				sdev_mid = Get standard deviation... power_sdev
				kurt_mid = Get kurtosis... power_kurt

				####################
				# gets center of gravity and skewness at 10%-intervals (10%, 20%, 30%,...) across the fricative interval
				
				#define numerical variable as 10 for 10%
				perc = 10
				#for look for duration k to 100%
				for k from 'perc' to 100
					#if remainder of k/perc == 0 do this set
					if k mod 'perc' == 0
						#find the start of percentage of duration in 10% chunks to measure now
						start_span = s_onset + (s_dur * ((k - 'perc') / 100))
						#find end of that chunk
						end_span = s_onset + (s_dur * (k / 100))
						select sound_one
						#Extract the selected 10% chunk
						Extract part... start_span end_span yes
						sound_two = selected ("Sound")
						select 'sound_two'
						#Apply band pass filter (same as above)
						Filter (pass Hann band)... startfreq endfreq smoothingfreq
						To Spectrum... Fast
						spectrum = selected ("Spectrum")
						select 'spectrum'
						
						#measures center of gravity and skewness using variables for power defined in form at start
						#Also truncates cog and skew to 6 characters (note: decimal '.' counts as a character)
						cog$ = Get centre of gravity... power_cog
						cog$ = left$ (cog$, 6)
						sdev$ = Get standard deviation... power_sdev
						sdev$ = left$ (sdev$, 6)
						skew$ = Get skewness... power_skew
						skew$ = left$ (skew$, 6)
						kurt$ = Get kurtosis... power_kurt
						kurt$ = left$ (kurt$, 6)

						#save results to variable with a new line added (tab separated)
						resultline$ = "'base_name$''tab$''interval_name$''tab$'
						...'s_onset''tab$''k''tab$''cog$''tab$''sdev$''tab$''skew$''tab$''kurt$'"
						...+newline$
						
						#Save results variable to output file for output_file_cog_ten$ (this is for cog and skewness at 10% intervals)
						resultline$ >> 'output_file_cog_ten$'

					endif
				endfor

				

				####################
				# creates results string and saves it output file for output_file_s$ (this is for mid 20% cog and skewness)

				resultline$ = "'base_name$''tab$''interval_name$''tab$'
				...'s_onset''tab$''s_offset''tab$'
				...'s_dur''tab$''cog_mid''tab$''sdev_mid''tab$''skew_mid''tab$'kurt_mid'"
				...+newline$

				resultline$ >> 'output_file_s$'

				####################
				# cleans up (removes items from objects list)
				
				select all
				minus 'sound_one'
				minus 'cur_grid'
				minus Strings textgrid_list
				Remove
			
			endif # end of if there is something in the interval
			#################### end if 

		endfor # next interval, j loop
		#################### end for loop
		

		nr_completed = nr_completed + 1

	else # if the file is not readable
		
		# prints an error message if the wav file isn't readable
		printline *** Error! No sound file 'input_sound_folder$''base_name$''ext1$' found. ***
	
		# removes the selected textgrid that doesn't have a matching sound file
		Remove

	endif # end of if file is readable
	################## end  if statement
	# cleans up
	select LongSound 'base_name$'
	plus TextGrid 'base_name$'
	Remove

endfor # next textgrid, i loop
############# end first for loop

# removes the textgrid list
select Strings textgrid_list
Remove

# announces finish
printline
printline Done! 
printline
printline 'nr_completed' of 'num_textgrids' TextGrid files processed
printline
printline The result files are named: 
printline "'output_file_s$'"  
printline "'output_file_cog_ten$'"
printline
printline and are in the folder where this script is saved
printline





#### end script file


