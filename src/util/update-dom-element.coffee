
###
# Function for updating the content of a dom element. The additional
# content and be prepended/appended to the elements children, or
# can replace the innerHTML of the element.
###

lemon.updateDOMElement = (el, method, html) ->
  switch method

    when 'append'
      div = document.createElement 'div'
      div.innerHTML = html
      el.appendChild div.firstChild
      return el.lastChild

    when 'prepend'
      div = document.createElement 'div'
      div.innerHTML = html
      el.insertBefore div.firstChild, el.firstChild
      return el.firstChild

    else
      el.innerHTML = html
      return el
