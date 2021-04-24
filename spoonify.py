import requests, json

# Get random recipes
def get_random_recipes(n, apiKey, verify = True):
      response = requests.get(
            url = 'https://api.spoonacular.com/recipes/random?apiKey=' + str(apiKey) + '&number=' + str(n),
            verify = verify
      )
      try:
            recipes = response.json()
            return recipes
      except:
            print(response.status_code + " - " + response.reason)
