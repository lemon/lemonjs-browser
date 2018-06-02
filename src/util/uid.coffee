
###
# Function for generating a unique identifier
###

lemon.uid = ->
  return "_#{++lemon.uid.n}"
lemon.uid.n = 0
