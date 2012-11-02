define ['jquery'], ($) ->
  (_main, modules...) ->
    $ ->
      for module in modules
        for selector, action of module
          if not selector or $(selector).length > 0
            try
              action.call $(selector)
            catch err
              console.error(err)
