TO DO
=====

Frinex info
===========

Main page showing projects
http://frinexbuild.mpi.nl/

Test version at
https://frinexstaging.mpi.nl/typicality_rating/


Data
====

- Check the quality and structure of the data!
- Verify that I can distinguish catch and target trials!

To access the admin panel, go to:
https://frinexstaging.mpi.nl/typicality_rating-admin/
(pw needed)


RA (Iris)
=========

- Consent form
- Instructions in Dutch/English -- send UPDATED version
- Set up the experiment on the server / MPI subject database (without launching it yet), incl. template message sent out to participants
- Check Dutch words: plural/sing + de/het
- Dutch: "The object doesn't match the word"

- Check that everything looks all right, both the experiment itself and all the small admin around it


Experiment build
================

- Indicate self-rated L2 English proficiency
- In Dutch: Text for "Word doesn't match the picture" 
- Adjust Dutch instructions to match English
- In items/stimuli: Adjust verb for plural forms
- Change label shown on top of screen (e.g., "dutch_ratings", etc.)
- Rating instructions: Add "If you don't know the word, click on the corresponding button."


Qs Maarten
==========

0)
Password for admin panel to access data

1)
Collect L2 profifiency ratings?

2)
How come English rating task has 2 additional slides compared to Dutch ratings (approx L188-9):

    <randomGrouping storageField="item">
        <tag>english_ratings</tag>



Other
=====

- Remove TaskOrder from info screen: I think this is line <metadataField fieldName="TaskOrder"/>
- Provide TaskOrder in the link --> Add "?TaskOrder=A" or "?TaskOrder=B" at the end. E.g., https://frinexproduction.mpi.nl/typicality_rating/?TaskOrder=B
