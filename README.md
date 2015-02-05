#Provision
A new way to manage provisioning profiles.

###Preamble
Although I've been developing iOS apps for several years, this is my first attempt at an OS X app. If you look in the code you're likely to see a ton of stupid decisions on my part that occurred over the ~8 hours I spent building this + learning parts of AppKit to make it work. If anyone has some OS X dev experience they can offer to help this thing out (or even better, design!) I'd be very appreciative.

###Current Features
Right now Provision has the following:

<ul>
<li>Automatically remove duplicate profiles</li>
<li>Automatically remove expired profiles</li>
<li>Delete provisioning profiles</li>
<li>Import new profiles (while checking for duplicates or newer copies)</li>
<li>Search profiles</li>
<li>View metadata for provisioning profiles</li>
<li>Double-click to open file in Finder</li>
</ul>

Not bad for ~8 hours!

###Roadmap
Here's where I want this to go:
<ul>
<li>Monitoring the Downloads folder for new profiles, then auto-importing them</li>
<li>Automatic, continous cleanup of expired / duplicate profiles</li>
<li>Bonjour syncing for teams</li>
<li>Syncing profiles with Dropbox / Server / etc.</li>
<li>Monitor selected project folders and auto-importing profiles. This would allow provisioning profiles to be version controlled, and auto-detectd / installed for fresh checkouts. Great for teams!</li>
<li>Real app name</li>
<li>Real app icon</li>
<li>Icons for the rest of the app</li>
</ul>

If you can help with any of this, or have questions. Feel free to drop me a line. I hope you like the beginnings of this and find it useful.
