import requests, json

# Get random recipes
def get_random_recipes(apiKey, n = 100, verify = True):
      
      if n > 100: n = 100
      if n < 1: n = 1
      
      url = 'https://api.spoonacular.com/recipes/random?apiKey=' + str(apiKey) + '&number=' + str(int(n))
      response = requests.get(url = url, verify = verify)
      
      try:
            recipes = response.json()
            return recipes
      except:
            print(str(response.status_code) + " - " + response.reason)
