
###
# Function for toggling a class name on an element
###

lemon.toggleClass = (el, class_name) ->
  return unless el
  if lemon.hasClass el, class_name
    lemon.removeClass el, class_name
  else
    lemon.addClass el, class_name
