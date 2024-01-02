#  'Easy AutoGUI' for AHK-v2

- Easy AutoGUI for AHK-v2 is a modified version of Alguimist's 'Easy AutoGUI' GUI-Designer for basic and advanced creation.
  
- If you need help, or are having trouble getting started, here's the latest releases link.  [Direct Link](https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/releases/download/v1.7/Easy-Auto-GUI-v1.7-for-AHK-v2.2.1.zip)
- Make sure you also install autohotkey v2 [AHKv2Installer](https://www.autohotkey.com/download/ahk-v2.exe) 

- Requires AHKv2

#



![Produce_19](https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/assets/98753696/4c87427a-4079-4043-852e-bbc03a55c953)



# Credits:
This project is built upon years of hard work done by the individuals below. I played a very small part in bringing this to AHKv2, these individuals gave hundreds of hours to make these applications possible: 
- Easy AutoGUI was created by **Alguimist**, the founder of the **Adventure IDE** here https://sourceforge.net/projects/autogui/. 
- AHKv2converter was developed by https://github.com/mmikeww and https://github.com/dmtr99 among others.
- Boiler from the autohotkey.com forum, provided MessageBox Creator within the tools menu. https://www.autohotkey.com/boards/viewtopic.php?f=83&t=78253
- Their work served as the foundation for this project, I did very little work, just weaving the two solutions together. All the work was done by the creators just mentioned.
  
# How it works 
Easy AutoGUI is built on and operates from ahkv1. Launch_AutoGUI is a v2 wrapper handling conversion and launching (without the need for v1.0 install). 

- **Real-Time Conversion**: The process of conversion takes place in real-time within the integrated development environment (IDE).  
- **Rapid Cloning**: Cloning windows that contain over 1,000 lines is efficient, completing in less than one second.
- **Custom Contingencies**: Special measures have been implemented to reduce output errors. These adapt the ahkv2converter output to match the specific requirements of this use case.
- **Error-Free Goal**: After building a GUI for ahkv2, the expectation is that the code execution should be free of errors. While errors might occur, they are unexpected, and users should report them. The design intent is to achieve error-free output.
- **Code Modifications**: The Changes_of_note folder contains information about key modifications made to the base code, highlighting the unique aspects of the implementation.



# Contribution
All help big or small is appreciated. If you have an idea or find a problem, click the Issues tab and create issue or fork and pull. Thanks!
 
 
# DPI fix

10/22/23 - I cannot dig through the code as Im traveling ATM. Here's a quick fix for small display / laptop users who run into small font, ill-fitting windows, etc. 

Right click properties on exe-

![image](https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/assets/98753696/e5ba25af-e35d-4e2c-b878-6fd56216f114)  ![image](https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2/assets/98753696/e2619da9-1c4e-49a6-b3d9-93f6fe6d48a0)




- Instructions: Launch from Launch_AutoGUI
- I have accounted for changes such as naming of "menubar" but there will be unforseen errors. Please notify me of those changes that need to be made in the output v2 conversion. 
 
