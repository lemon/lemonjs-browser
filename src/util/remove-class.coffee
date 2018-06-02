
###
# Function for removing a class to a dom element
###

lemon.removeClass = (el, class_names) ->
  return unless el
  for class_name in class_names.split ' '
    if el.classList
      el.classList.remove class_name
    else
      re = new RegExp "(^|\\b)#{class_name}(\\b|$)", 'gi'
      el.className = el.className.replace re, ' '
