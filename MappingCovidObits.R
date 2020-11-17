#title:  "Mapping Deaths by COVID-19 in Brazil"
#author: "Natália Faraj Murad"
#e-mail:  nataliafmurad@gmail.com 

#This script uses the data from Brasil.io to map the total number of deaths by
#COVID-19 in a map.

#Setting directory
#getwd()
#setwd("seu_diretorio")

#Loading packages
#Format the dataset
library(dplyr)
library(tidyverse)
library(reshape2)
library(data.table)
#Get coordinates
library(ggmap)
#Plot
library(ggplot2)
library(leaflet)

#Reading the dataset
coviddata <- fread("caso_full.csv", sep = ",", header = T,
                   na.strings = "NA", select = c("city", 
                                                 "city_ibge_code",
                                                 "date",
                                                 "epidemiological_week",
                                                 "place_type", "state",
                                                 "new_deaths"))
#Removing rows containing NA
coviddata <- drop_na(coviddata)

#Formatting dates
coviddata$date <- as.Date(coviddata$date)
#str(coviddata)

#Defining state regions and creating region column
norte <- c("AM", "RR", "AP", "PA", "TO", "RO", "AC")
nordeste <- c("MA", "PI", "CE", "RN", "PE", "PB", "SE", "AL", "BA")
centro_oeste <- c("MT", "MS", "GO", "DF")
sudeste <- c("SP", "RJ", "ES", "MG")
sul <- c("PR", "SC", "RS")

coviddata <- coviddata %>%
mutate(region = case_when(coviddata$state %in%
                          norte==TRUE ~ "North",
                          coviddata$state %in%
                          nordeste==TRUE ~ "Northeast",
                          coviddata$state %in% 
                          centro_oeste==TRUE ~ "Midwest",
                          coviddata$state %in%
                          sudeste==TRUE ~ "Southeast",
                          coviddata$state %in%
                          sul==TRUE ~ "South"))

#Plotting deaths by reagion each epidemiological week
#Calculate total number of deaths per region per week
region_totals <- coviddata                %>%
  filter(place_type == "state")         %>%
  group_by(epidemiological_week,region) %>%  
  summarize(tot = sum(new_deaths))

#Plot
region_totals %>% 
ggplot(aes(x = epidemiological_week, 
           y = tot,
           group = region, color = region))        + 
geom_line()                                        +  
geom_point()                                       +
xlab("Epidemiological Week")                       +
ylab("Total Deaths")                               +
theme(plot.title = element_text(hjust = 0.5))      +
ggtitle("Deaths by COVID-19 per Region of Brazil") +
theme_classic()

#Total by region
somaregiao <- tapply(region_totals$tot, region_totals$region, sum)

#barplot(somaregiao,
#        horiz = TRUE,
#        xlab = "Number of Deaths by COVID-19",
#        ylab = "Region",
#        col = c("red"))
pie(somaregiao, main = "Total Deaths by COVID-19 per Region")

#Filter the lines that contain the information by state
state <- coviddata %>% 
  filter(place_type == "state")

#Plot
state %>% 
    ggplot(aes(x =state, y = new_deaths)) + geom_bar(stat = "identity") +
    ylab("New Deaths") + xlab("State") +
    theme(plot.title = element_text(hjust = 0.5)) +
    ggtitle("Deaths by COVID-19 per State - Brazil") +
    theme_classic()

#Calculating total deaths by city
#Filtering the rows with city information
covidcity <- coviddata    %>%
  filter(place_type == "city")

#Getting the sum
covidcity                 %>% 
  group_by(date,region) %>% 
  summarize(tot=sum(new_deaths)) -> totals

#Creating the column with the information of the cities that will be searched
brazil <- rep("Brazil", length(unique(covidcity$city)))
covidcity$citst <- paste0(covidcity$city, sep = " ", covidcity$state,
                          sep = " ", "Brazil")

#key <- "YOUR KEY HERE"
register_google(key, account_type = "standard")

#If your dataset if very big, it can take a time to search all cities
longlat <- geocode(covidcity$citst) %>% 
  mutate(loc = covidcity$citst)

#Write this object in a csv file to use later and do not need make the search again.
#write.csv(longlat, "longlat.csv")

#Joining information of the 2 dataframes by the name of the city
covidcity %>%
    group_by(citst)                              %>%
    summarize(cases = sum(new_deaths))           %>% 
    inner_join(longlat, by = c("citst" = "loc")) %>% 
    mutate(LatLon = paste(lat, lon, sep = ":"))  -> formapping

#Formatting the object
num_of_times_to_repeat <- formapping$cases
long_formapping <- formapping[rep(seq_len(nrow(formapping)),
                                  num_of_times_to_repeat),]
#Plot the map
leaflet(long_formapping)     %>% 
  addTiles()                 %>% 
  addMarkers(clusterOptions = markerClusterOptions())