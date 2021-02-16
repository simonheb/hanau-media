# hanau-media
tracing the media coverage of the hanau attack

# data faq
## how do you find articles matching a particular attack?
I plug search terms into the news websites search interfaces that identify the articles mentioning each attack fairly accurately. to achieve this, I combine
a location/event-specific prefix with a suffix that indicates an attack. articles have to contain both parts.
the suffixes are "attentat", "terror", and "anschlag". the prefies are attach specific:

| Attack  |  prefix 1 |  prefix 2 |  prefix 3 |
|---------|---------------|---------------|---------------|
|[Hanau](https://de.wikipedia.org/wiki/Anschlag_in_Hanau_2020)    |hanau          |kesselstadt    |tobias r*****  |
|[Berlin](https://de.wikipedia.org/wiki/Anschlag_auf_den_Berliner_Weihnachtsmarkt_an_der_Ged%C3%A4chtniskirche)   |breitscheidplatz|berliner weihnachtsmarkt|anis a***|
|[Ansbach](https://de.wikipedia.org/wiki/Sprengstoffanschlag_von_Ansbach)  |ansbach        |fränkisches musikfestival|mohammed d*****|
|[Würzburg](https://de.wikipedia.org/wiki/Anschlag_in_einer_Regionalbahn_bei_W%C3%BCrzburg) |würzburg regionalbahn|Winterhausen|riaz khan a*****|

(attacker's names are only anonymized in this table. #SayTheirNames is for the victims only.)

I plug in all possible combinations of these terms with the suffixes into the search engines at www.spiegel.de/suche, www.faz.net/suche/, www.sueddeutsche.de/news, and bild.de/suche.bild.html and save the returned articles. of course, several articles come up for multiple searches, these duplicates are removed and only counted as one.


## why are "Welt" and "Focus" not covered?
because they have shitty search interfaces on their websites, which do not allow to search for older articles

# data pipeline
1. `pseudo apis.R` contains routines to access websearches of news websites.
1. `1 - download search results.R` downloads search results from all news websites.
1. `2 - clean data.R` cleans the search results to prepare them to be used in the app.
1. `app.R` is the shiny app.
1. `*.RDS` store the latest data files after each step in the data pipeline.

