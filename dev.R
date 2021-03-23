library(tidyverse)
library(httr)
library(reticulate)
library(base64enc)


auth <- list(
      SPOTIFY_CLIENTID = Sys.getenv("SPOTIFY_CLIENTID"),
      SPOTIFY_CLIENTSECRET = Sys.getenv("SPOTIFY_CLIENTSECRET"),
      SPOONACULAR_APIKEY = Sys.getenv("SPOONACULAR_APIKEY")
)

source_python("spotify.py")


token <- access_token(auth$SPOTIFY_CLIENTID, auth$SPOTIFY_CLIENTSECRET)



r = GET("https://api.spotify.com/v1/artists/2CiRpkhwIUTCnAThfOxnZW", add_headers(Authorization = paste("Bearer", token)))
r = GET("https://api.spotify.com/v1/artists/2CiRpkhwIUTCnAThfOxnZW/albums", add_headers(Authorization = paste("Bearer", token)))


http_status(r)
content(r)

client_credentials <- paste(auth$SPOTIFY_CLIENTID, auth$SPOTIFY_CLIENTSECRET, sep = ":") %>%
      charToRaw() %>%
      base64encode() %>%
      base64decode()
      
r = POST(
      url = 'https://accounts.spotify.com/api/token', 
      body = list(grant_type = 'client_credentials'), 
      add_headers(Authorization = paste("Basic", client_credentials))
)
























