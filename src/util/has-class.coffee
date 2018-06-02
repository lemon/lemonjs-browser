
###
# Function for checking if an element has a class
###

lemon.hasClass = (el, class_name) ->
  return unless el
  if el.classList
    el.classList.contains class_name
  else
    new RegExp('(^| )' + class_name + '( |$)', 'gi').test el.className
