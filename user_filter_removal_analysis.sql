
/*
Tasked with comparing filter removal behavior of users to inform design decisions. Do 
users remove single filter chips one at a time when trying to remove multiple filters, or
do they opt for the 'remove all' button to do it all at once. Not a straightforward question
as the events that trick filter removal can only tell us if a single filter or clear-all
was used -> If a user has 5 filters active and hits the remove-all button, that gets
recorded on a single line, but if the user removed each filter individually, that would be 5
records. This skews the analysis to present single filter removal as much more common if not 
considered in some way. 
*/

