# A modified version of 'Easy AutoGUI' for ahk-v2

I'll be adding more details here soon.

- Auto-GUI-v2 credit to Alguimist - https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901

- AHKv2converter credit to https://github.com/mmikeww/AHK-v2-script-converter

I did very little work, just weaving the two solutions together. All the work was done by the creators just mentioned.

# How it works 
- this runs Easy AutoGUI on ahkv1
- Conversion happens when selecting "Save" or "Save as..." [now updates in IDE] 
- function-call converts to v2 with ahkv2converter 
- autogui has custom code posted in the changes_of_note folder
- works with embedded ahk exe's from ahkconverter, you do not need ahkv1 or v2, hypothetically this should run portably



Update: Live in IDE v2 code works. Example, cloning notepad++ to ahkv2. 

![giphy](https://user-images.githubusercontent.com/98753696/233808870-8ae299a7-1c44-48a4-bf4d-7c3fd820c4e4.gif)



- Instructions: Launch from Launch_AutoGUI
- I have accounted for changes such as naming of "menubar" but there will be unforseen errors. Please notify me of those changes that need to be made in the output v2 conversion. 
 
