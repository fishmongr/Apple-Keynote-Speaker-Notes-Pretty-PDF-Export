# Custom Keynote PDF Export

This repo's tools allow you to have complete control over the design of Keynote PDF export with speaker notes. The default template will allow you to easily generate a nicely formatted PDF with full-width slide at top of each page and full-width presenter notes below it as nicely formatted bulleted points. Once you're familiar you can run this script and generate nice looking PDFs in under 5 minutes. See this example of an: [exported PDF](example/AI-sept2017.pdf)

### Prerequisites

This worlfkow Utilizes AppleScript and Adobe Indesign but you don't need to know either. AppleScript should automaticlaly come installed on your Mac. You do need Adobe Indesign installed however. 

### How to use

**1. First, generate a folder of PNGs, one for each full screen slide**

In KeyNote: Open KeyNote presentation and File > Export > Images. Use Format PNG. Save using name "slide" in this project's folder. It'll create a new folder called "slide" with each slide as "slide.001.png" etc. 

**2. Then generate the CSV file export of your presentation:**

Make sure KeyNote with your presentation is open. In this repo double click keynote.scpt. It opens in Script Editor. Click the gray play icon in it. It will generate a "datamap.csv" in the same folder within a few seconds.  
This generated file is a comma-deliminated text file containing a mapping of your speaker notes to pages. The images from Step 1 and text generated here will be merged into the final PDF in the final step.


**3. Then use the Indesign template to generate a unique Indesign project using our CSV and thumbnails (easier then it sounds)**

3.1. In the project folder click on template.indd to open it. It will tell you sources have changed. Click "Update Links". It will finish opening.  
3.2. Open Window > Utilities > Data Merge panel. Click on the little hamburger icon in top right of this panel > Create Merged Document.  
3.3. In the popup "Create Merged Document" panel, click OK. Voila! A new InDesign project has been created in a new tab. Save that as your project specific template. In the future you can use this new custom template for any changes in export design for your current project.  
3.4. Next step is to fix linebreaks. In the datamap.csv file we had to temporarily replace lines breaks in presenter notes with the word "LINEBREAK" for this process to work. We'll replace them back with real linebreaks in Indesign. In the Indesign File Menu > Edit > Find/Change > switch to TEXT tab. Enter "[LINEBREAK]" and "Change to" put "^p" paragraph symbol. Then hit Change All (if Chagne All is greyed out just hit Find Next first).  
3.5. Optional customization. Click on Pages > A-Master anytime you want to change template design accross all pages. Otherwise you can make changes directly on specific pages.  
3.6. Final PDF export. In the Indesign File Menu > Export... and export PDF as normal.  

**Mitigating errors encountered:**

On step 3.3 or 3.6  
Indesign may prompt with a "Overset Text Report" which is a report of how many pages have too much text. Text is clipping off of the noted pges. The PDF export can hold quite a lot of text but it does have it's limits. You can continue the export and see what the final PDF export looks like first but will likely need to reformet your text, cut it down, or update the export design to fit more text (smaller text size, etc). You can re-format the text in your presentation and re-export or just modify the text directly on those pages in Indesign.  
Another error that may pop up is regarding missing images. This means you didn't export the images to the right place. Be sure the images are exported as PNG. They should be under the same proect folder under a /slide/ generated by Keynote with names staring with slide.001.png.  

**Other tips:**

The formatting of bullet points are done through a bit of an Indesign hack as described [here](https://indesignsecrets.com/controlling-line-breaks-with-data-merge.php) with custom Paragraph Style options that you can tweak further.





