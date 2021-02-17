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

i plug in all possible combinations of these terms with the suffixes into the search engines at www.spiegel.de/suche, www.faz.net/suche/, www.sueddeutsche.de/news, and bild.de/suche.bild.html and save the returned articles. of course, several articles come up for multiple searches, these duplicates are removed and only counted as one.


## why are "Welt" and "Focus" not covered?
because they have shitty search interfaces on their websites, which do not allow to search for older articles

## why don't you include newspaper/attack XYZ
i am happy to do that. i am also happy if you do that. this project is open source. i would just suggest that if you add something to it indepently from me, than please consider also pushing your changes to this repository so that we can all discuss the results.

## i found an article that matches your search terms, but does not actually talk about the attack in question
that is well possible. there are a number of articles to which this may apply. i assume this does not drive the overall pattern, but are open to suggestions to refine the search terms or the analysis.

## how do you interact with each specific search interface and how do you treat different subjournals (spiegel plus, bento, etc.?)
the different search interfaces require different ways of finetuning. this section provides a short overview of these measures.

### Spiegel
spiegel allows for some filtering. i restrict the search to anything that is published in "DER SPIEGEL" or "SPIEGEL+", thus effectively excluding "SPIEGEL-PRINT", "SPIEGEL International", etc. bento.de was discontinued and merged into spiegel, this has some bearing on the results here as bento.de ran a series of interviews with the hanau victims family that significantly alter the curves around august 2020, which would be lower without the bento.de articles.

### SZ
sz allows filtering results. i restrict the search to "articles" only (no videos, galeries, or other links) and only to those that can be attributed to "sueddeutsche.de", thus effectively excluding dpa news. sz also has a slighly different format for search queries. to ensure matching results I thus replace spaces with " AND ". the search term "hanau anschlag" thus becomes "hanau AND anschlag". also, only for the hanau attack, it seems that sz had a policy of not spelling out the attackers full lastname, which is why replace that with an abbreviated "tobias r" in all of the search queries.

### FAZ
sz allows filtering results. i restrict the search to "articles" only (no videos, galeries, etc).


### Bild
does not allow for subcategories in their search interface, returned results include dpa/agency texts, eilmeldungen and others

# data pipeline
1. `pseudo apis.R` contains routines to access websearches of news websites.
1. `1 - download search results.R` downloads search results from all news websites.
1. `2 - clean data.R` cleans the search results to prepare them to be used in the app.
1. `app.R` is the shiny app.
1. `*.RDS` store the latest data files after each step in the data pipeline.

#todo:
*allow to filter-out bento?
*add halle anschlag?