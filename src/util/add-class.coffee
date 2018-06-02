
###
# Function for adding a class to a dom element
###

lemon.addClass = (el, class_names) ->
  return unless el
  for class_name in class_names.split ' '
    if el.classList
      el.classList.add class_name
    else
      el.className += ' ' + class_name
