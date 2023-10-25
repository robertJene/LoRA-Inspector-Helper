# LoRA-Inspector-Helper
scripts to help using lora-inspector.py from here: https://github.com/rockerBOO/lora-inspector


LoRA_average_weights.txt - made by LoRA_Inspector_helper.vbs
LoRA_average_weights.csv - made by LoRA_Inspector_helper.vbs
LoRA_inspector.bat
LoRA_Inspector_helper.vbs
lora-inspector.py

**INSTRUCTIONS**

Put these files in the same folder as lora-inspector.py:
LoRA_inspector.bat
LoRA_Inspector_helper.vbs

Then run the batch file LoRA_inspector.bat, and use option F to put in the path to where your LoRA files are


**Option F**
put in the path to where your LoRA files are

**Option 1**
run the inspection with lora-inspector.py and display the results in the command line console

**Option 2**
use this to create a batch file that displays the data in a different format as well as create a .CSV file at the same time
_the steps below are necessary because lora-inspector.py does not have an option to output to text file so I could just parse that_

    Instructions:
      1. Run this on a folder with LoRA files in it
      2. When it is done, press Ctr+A to select all, then Ctrl+C to copy
      3. Open LoRA_average_weights.txt and press Ctrl+V to paste
      4. Run LoRA_inspector_helper.vbs to create the CSV and batch file

**Option 3**
use this option to output .JSON files to a meta folder with the same names as the LoRA files that are inspected



