# :microscope: Covid-19 Data Analysis

Some analysis of Covid-19 data using several tools and datasets.

### Mapping Covid Deaths with leaflet

MappingCovidObits.R - script in R to create an interactive map of the obits by COVID-19.

casos_full.csv - the dataset containing the number of deaths by city per day. (>25MB - download it at https://brasil.io/dataset/covid19/caso_full/). The dataset used here was dowloaded in 11-17-2020

[MappingCovidObits.html](https://rpubs.com/natmurad/mapcovid) - the report containing the code and comments about the analysis.

### Extract, Transform & Load Covid Data with pandas & pandera

[ETLCovidData](https://github.com/natmurad/covidDataExploration/blob/main/ETLCovidData.ipynb) - Notebook with a pipeline to prepare and filter Covid-19 Data from [CSSEGI Sand Data Github](https://github.com/CSSEGISandData/COVID-19) in real time.
