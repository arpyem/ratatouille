library(tidyverse)
library(httr)
library(reticulate)
library(base64enc)
library(jsonlite)


# Verify HTTP requests - TRUE for deployment, FALSE for testing in case of VPN
verify <- FALSE


# API call functions (requests)
source_python("spotify.py")
source_python("spoonify.py")


# Authentication
auth <- list(
      SPOTIFY_CLIENTID = Sys.getenv("SPOTIFY_CLIENTID"),
      SPOTIFY_CLIENTSECRET = Sys.getenv("SPOTIFY_CLIENTSECRET"),
      SPOONACULAR_APIKEY = Sys.getenv("SPOONACULAR_APIKEY")
)

token <- get_access_token(auth$SPOTIFY_CLIENTID, auth$SPOTIFY_CLIENTSECRET, verify)


# Sample music data
featured_playlists <- get_featured_playlists(token, verify)


# Split vector of ids into a list of smaller vectors with a maximum size for API call limits
split_ids_to_chunks <- function(ids, chunk_size = 100) {
      
      # Calculate how many chunks are needed for the unique ids and assign them to a chunk
      ids <- unique(ids)
      chunk_ids <- ceiling(1:length(ids) / chunk_size) 
      
      # List ids by their assigned chunk
      chunk_ids %>%
            unique() %>%
            map(function(chunk) {
                  ids[chunk_ids == chunk]
            })
      
      
}


# Get table of tracks with audio features and other metadata that could be used for modeling
df_track = featured_playlists$playlists$items %>%
# df_track = featured_playlists$playlists$items[1:2] %>% # for testing
      map(function(featured_playlist) {
            
            # Get playlist items
            message("getting playlist: ", featured_playlist$name)
            playlist <- get_playlist(featured_playlist$id, token, verify)
            
            
            # Extract details for each track in playlist
            track_details <- playlist$items %>%
                  map(function(track) {
                        
                        # Return a row for each artist
                        artists <- track$track$artists %>%
                              map(function(artist) {
                                    
                                    tibble(
                                          artist_id = artist$id,
                                          artist_name = artist$name,
                                          artist_url = artist$external_urls$spotify
                                    )
                                    
                              }) %>%
                              bind_rows()
                        
                        # Track data
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
            
            
            # Set up for API calls to Tracks API (limit = 100)
            track_ids <- split_ids_to_chunks(track_details$track_id)
            
            # Get audio features for each track
            message("    getting audio features")
            track_features <- track_ids %>%
                  map(function(chunk) {
                        track_features <- get_track_features(chunk, token, verify)
                        track_features$audio_features
                  }) %>%
                  bind_rows()
            
            
            # Set up for API calls to Artists API (limit = 50)
            artist_ids <- split_ids_to_chunks(track_details$artist_id, chunk_size = 50)
            
            # Get genres from artist data
            message("    getting genres")
            genres <- artist_ids %>%
                  map(function(chunk) {
                        
                        artist_details <- get_artists(chunk, token, verify)
                        
                        # Get genre data for each artist
                        artist_details$artists %>%
                              map(function(artist) {
                                    
                                    genres <- artist$genres
                                    
                                    # Artists with no genre data return an empty list - set to NA to create dataframe
                                    if (length(genres) < 1) {
                                          genres <- NA
                                    }
                                    
                                    # Return a row for each genre
                                    tibble(
                                          id = artist$id,
                                          genre = genres
                                    )
                                    
                              }) %>%
                              bind_rows()
                        
                  }) %>%
                  bind_rows()
            
            
            # Combine data
            track_details %>%
                  left_join(track_features, by = c("track_id" = "id")) %>%
                  left_join(genres, by = c("artist_id" = "id"))
            
      }) %>%
      bind_rows()


# Cache data (for development)
write_rds(x = df_track, file = "data/tracks_featured.rds")




# Get random recipes
recipes <- get_random_recipes(auth$SPOONACULAR_APIKEY, verify = verify)

df_recipe <- recipes$recipes %>%
      map(function(recipe) {
            
            recipe_id <- recipe$id
            
            ingredients <- recipe$extendedIngredients %>%
                  map(function(ingredient) {
                        
                        if (is.null(ingredient$id)) {
                              ingredient_id <- NA
                        } else {
                              ingredient_id <- ingredient$id
                        }
                        
                        if (is.null(ingredient$nameClean)) {
                              ingredient_name <- ingredient$nameClean
                        } else {
                              ingredient_name <- ingredient$name
                        }
                        
                        list(
                              recipe_id = recipe_id,
                              ingredient_id = ingredient_id,
                              ingredient_name = ingredient_name,
                              amount = ingredient$amount,
                              unit = ingredient$unit,
                              aisle = ingredient$aisle,
                              ingredient_description = ingredient$original
                        ) %>%
                              compact() %>%
                              data.frame()
                  }) %>%
                  bind_rows()
            
            recipe_details <- tibble(
                  recipe_id = recipe$id,
                  recipe_name = recipe$title,
                  prep_time = recipe$readyInMinutes,
                  servings = recipe$servings,
                  cuisine = paste0(recipe$cuisines, collapse = ","),
                  dish_type = paste0(recipe$dishTypes, collapse = ","),
                  diet = paste0(recipe$diets, collapse = ","),
                  occasion = paste0(recipe$occasions, collapse = ","),
                  instructions = recipe$instructions,
                  smart_points = recipe$weightWatcherSmartPoints,
                  spoonacular_score = recipe$spoonacularScore,
                  health_score = recipe$healthScore,
                  price_per_serving = recipe$pricePerServing,
                  recipe_source_url = recipe$sourceUrl,
                  recipe_source = recipe$sourceName
            )
            
            recipe_details %>%
                  left_join(ingredients, by = "recipe_id")
            
      }) %>%
      bind_rows()


# Cache data (for development)
write_rds(x = df_track, file = "data/recipes_random.rds")




