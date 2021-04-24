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




token <- get_access_token(auth$SPOTIFY_CLIENTID, auth$SPOTIFY_CLIENTSECRET, verify = FALSE)

featured_playlists <- get_featured_playlists(token, verify = FALSE)

playlist_ids <- featured_playlists$playlists$items %>%
      map_chr(function(playlist) {
            playlist$id
      })





# Split vector of ids into a list of smaller vectors with a maximum size for API call limits
split_ids_to_chunks <- function(ids, chunk_size = 100) {
      
      ids <- unique(ids)
      chunk_ids <- ceiling(1:length(ids) / chunk_size) 
      
      chunk_ids %>%
            unique() %>%
            map(function(chunk) {
                  ids[chunk_ids == chunk]
            })
      
      
}




# test = featured_playlists$playlists$items %>%
test = featured_playlists$playlists$items[1:2] %>%
      map(function(featured_playlist) {
            
            playlist <- get_playlist(featured_playlist$id, token, verify = FALSE)
            
            track_details <- playlist$items %>%
                  map(function(track) {
                        
                        artists <- track$track$artists %>%
                              map(function(artist) {
                                    
                                    tibble(
                                          artist_id = artist$id,
                                          artist_name = artist$name,
                                          artist_url = artist$external_urls$spotify
                                    )
                                    
                              }) %>%
                              bind_rows()
                        
                        tibble(
                              track_id = track$track$id,
                              track_name = track$track$name,
                              track_url = track$track$external_urls$spotify,
                              track_popularity = track$track$popularity,
                              album_id = track$track$album$id,
                              album_name = track$track$album$name,
                              album_url = track$track$album$external_urls$spotify,
                              release_date = track$track$album$release_date,
                              artists
                        )
                        
                  }) %>%
                  bind_rows()
            
            track_ids <- split_ids_to_chunks(track_details$track_id)
            
            track_features <- track_ids %>%
                  map(function(chunk) {
                        track_features <- get_track_features(chunk, token, verify = FALSE)
                        track_features$audio_features
                  }) %>%
                  bind_rows()
            
      })




test2 = left_join(test, track_features, by = c("track_id" = "id"))




playlist <- get_playlist(featured_playlists$playlists$items[[3]]$id, token, verify = FALSE)

playlist$items[[1]]$track$artists %>%
      map(function(artist) {
            
            tibble(
                  id = artist$id,
                  name = artist$name,
                  url = artist$external_urls$spotify
            )
            
      })





track_ids <- playlist$items %>%
      map_chr(function(track) {
            track$track$id
      })


track_features <- get_track_features(track_ids, token, verify = FALSE)

track_features$audio_features %>% bind_rows()

tracks <- get_tracks(track_ids[1:50], token, verify = FALSE)


tracks$tracks[[1]]


album_ids <- playlist$items %>%
      map_chr(function(track) {
            track$track$album$id
      })

albums <- get_albums(album_ids[1:20], token, FALSE)


albums$albums[[1]]

albums$albums[[1]]$genres

albums$albums %>% map(function(album) names(album))


playlist$items[[1]]$track$artists

artist_ids <- playlist$items %>%
      map(function(track){
            artists <- track$track$artists
            artists %>%
                  map_chr(function(artist) {
                        artist$id
                  })
      }) %>%
      reduce(c)


artists <- get_artists(artist_ids[1:50], token, FALSE)

artists$artists[[1]]$genres

genres <- artists$artists %>%
      map(function(artist) {
            artist$genres
      })



























