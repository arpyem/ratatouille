import requests, json, base64


# Get token for authentication - pass result into other API calls
def get_access_token(client_id, client_secret, verify = True):
      
      # Encode raw credentials to API spec (Basic)
      client_credentials_raw = str(client_id) + ":" + str(client_secret)
      client_credentials_encoded = base64.b64encode(client_credentials_raw.encode("utf-8"))
      client_credentials = client_credentials_encoded.decode("utf-8")
      
      response = requests.post(
            url = "https://accounts.spotify.com/api/token", 
            data = {"grant_type": "client_credentials"}, 
            headers = {"Authorization": "Basic " + client_credentials},
            verify = verify
      )
      try:
            token = response.json()['access_token']
            return token
      except:
            print(response.status_code + " - " + response.reason)



# Browse featured playlists
def get_featured_playlists(token, verify = True):
      response = requests.get(
            url = "https://api.spotify.com/v1/browse/featured-playlists", 
            headers = {"Authorization": "Bearer " + token}, 
            verify = verify
      )
      try:
            featured_playlists = response.json()
            return featured_playlists
      except:
            print(response.status_code + " - " + response.reason)
      
      

# Get playlist items using playlist ID
def get_playlist(playlist_id, token, verify = True):
      response = requests.get(
            url = 'https://api.spotify.com/v1/playlists/' + str(playlist_id)  + '/tracks', 
            headers = {"Authorization": "Bearer " + token}, 
            verify = verify
      )
      try:
            tracks = response.json()
            return tracks
      except:
            print(response.status_code + " - " + response.reason)


# Get track features using track ID - max 100
# https://developer.spotify.com/documentation/web-api/reference/#object-audiofeaturesobject
def get_track_features(track_ids, token, verify = True):
      
      # Collapse multiple track ids comma separated unless there is only one track id
      if isinstance(track_ids, list):
            track_ids = list(map(str, track_ids))
            track_ids = ','.join(track_ids)
      else:
            track_ids = str(track_ids)
      
      response = requests.get(
            url = 'https://api.spotify.com/v1/audio-features?ids=' + track_ids, 
            headers = {"Authorization": "Bearer " + str(token)}, 
            verify = verify
      )
      try:
             track_features = response.json()
             return track_features
      except:
            print(str(response.status_code) + " - " + response.reason)



# Get track details using track ID - max 50
def get_tracks(track_ids, token, verify = True):
      
      # Collapse multiple track ids comma separated unless there is only one track id
      if isinstance(track_ids, list):
            track_ids = list(map(str, track_ids))
            track_ids = ','.join(track_ids)
      else:
            track_ids = str(track_ids)
      
      response = requests.get(
            url = 'https://api.spotify.com/v1/tracks?ids=' + track_ids, 
            headers = {"Authorization": "Bearer " + str(token)}, 
            verify = verify
      )
      try:
             tracks = response.json()
             return tracks
      except:
            print(str(response.status_code) + " - " + response.reason)




# Get album details (extended track details) using album ID - max 20
def get_albums(album_ids, token, verify = True):
      
      # Collapse multiple track ids comma separated unless there is only one track id
      if isinstance(album_ids, list):
            album_ids = list(map(str, album_ids))
            album_ids = ','.join(album_ids)
      else:
            album_ids = str(album_ids)
      
      response = requests.get(
            url = 'https://api.spotify.com/v1/albums?ids=' + album_ids, 
            headers = {"Authorization": "Bearer " + str(token)}, 
            verify = verify
      )
      try:
             albums = response.json()
             return albums
      except:
            print(str(response.status_code) + " - " + response.reason)




# Get artist details using artist ID - max 50
def get_artists(artist_ids, token, verify = True):
      
      # Collapse multiple track ids comma separated unless there is only one track id
      if isinstance(artist_ids, list):
            artist_ids = list(map(str, artist_ids))
            artist_ids = ','.join(artist_ids)
      else:
            artist_ids = str(artist_ids)
      
      response = requests.get(
            url = 'https://api.spotify.com/v1/artists?ids=' + artist_ids, 
            headers = {"Authorization": "Bearer " + str(token)}, 
            verify = verify
      )
      try:
             artists = response.json()
             return artists
      except:
            print(str(response.status_code) + " - " + response.reason)




