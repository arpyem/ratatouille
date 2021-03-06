import requests, json, base64

def access_token(client_id, client_secret, verify = False):
    client_credentials_raw = client_id + ":" + client_secret
    client_credentials_encoded = base64.b64encode(client_credentials_raw.encode("utf-8"))
    client_credentials = client_credentials_encoded.decode("utf-8")
    response = requests.post(
            url = "https://accounts.spotify.com/api/token", 
            data = {"grant_type": "client_credentials"}, 
            headers = {"Authorization": "Basic " + client_credentials},
            verify = verify
        )
    try:
        return response.json()['access_token']
    except:
        print(response.status_code + " - " + response.reason)


token = access_token(r.auth['SPOTIFY_CLIENTID'], r.auth['SPOTIFY_CLIENTSECRET'])

artist_id = '2CiRpkhwIUTCnAThfOxnZW'

request = requests.get(
      url = "https://api.spotify.com/v1/artists/" + artist_id + "/top-tracks", 
      headers = {"Authorization": "Bearer " + access_token(r.auth['SPOTIFY_CLIENTID'], r.auth['SPOTIFY_CLIENTSECRET'])}, 
      params = {"country": "US"},
      verify = False
)

top_tracks = request.json()


request = requests.get(
      url = "https://api.spotify.com/v1/browse/featured-playlists", 
      headers = {"Authorization": "Bearer " + access_token(r.auth['SPOTIFY_CLIENTID'], r.auth['SPOTIFY_CLIENTSECRET'])}, 
      verify = False
)


featured_playlists = request.json()

from pprint import pprint


pprint(featured_playlists)

for playlist in featured_playlists['playlists']['items']:
      playlist['name']
      playlist['id']
      


playlist_id = featured_playlists['playlists']['items'][0]['id']

request = requests.get(
      url = 'https://api.spotify.com/v1/playlists/' + playlist_id  + '/tracks', 
      headers = {"Authorization": "Bearer " + token}, 
      verify = False
)

tracks = request.json()

for artist in tracks['items'][0]['track']['artists']:
      artist['name']


for track in tracks['items']:
      track_name = track['track']['name']
      track_id = track['track']['id']
      track_artists = []
      for artist in track['track']['artists']:
            track_artists.append(artist['name'])


# https://developer.spotify.com/documentation/web-api/reference/#object-audiofeaturesobject

request = requests.get(
      url = 'https://api.spotify.com/v1/audio-features/' + track_id, 
      headers = {"Authorization": "Bearer " + token}, 
      verify = False
)

track_features = request.json()


track_features




# Get token for authentication - pass result into other API calls
def get_access_token(client_id, client_secret, verify = False):
      
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



# Get track features using track ID - https://developer.spotify.com/documentation/web-api/reference/#object-audiofeaturesobject
def get_track_features(track_id, token, verify = True):
      response = requests.get(
            url = 'https://api.spotify.com/v1/audio-features/' + str(track_id), 
            headers = {"Authorization": "Bearer " + token}, 
            verify = verify
      )
      try:
             track_features = response.json()
             return track_features
      except:
            print(response.status_code + " - " + response.reason)
     






request = requests.get(
      url = 'https://api.spoonacular.com/recipes/random?apiKey=' + r.auth['SPOONACULAR_APIKEY'] + '&number=100',
      verify = False
)

recipes = request.json()

len(recipes['recipes'])

from pprint import pprint

pprint(recipes['recipes'][0])



request = requests.get(
      url = 'https://api.spoonacular.com/recipes/random?apiKey=' + r.auth['SPOONACULAR_APIKEY'] + '&number=2',
      verify = False
)

recipes = request.json()



for recipe in recipes['recipes']:
      recipe['title']


# Get random recipes
def get_random_recipes(n, apiKey, verify = True):
      request = requests.get(
            url = 'https://api.spoonacular.com/recipes/random?apiKey=' + str(apiKey) + '&number=' + str(n),
            verify = verify
      )


with open('data/recipes_random.json', 'w') as file:
      json.dump(recipes, file)


