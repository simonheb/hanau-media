# hanau-media
tracing the media coverage of the hanau attack

# data pipeline
1. `pseudo apis.R` contains routines to access websearches of news websites.
1. `1 - download search results.R` downloads search results from all news websites.
1. `2 - clean data.R` cleans the search results to prepare them to be used in the app.
1. `app.R` is the shiny app.
1. `*.RDS` store the latest data files after each step in the data pipeline.
