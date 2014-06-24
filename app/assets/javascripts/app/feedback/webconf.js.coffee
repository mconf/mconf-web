$ ->
  if isOnPage 'feedback', 'webconf'

    clock = $(".countdown")
    startValue = 6
    currentValue = startValue

    clock.text(currentValue)
    interval = setInterval( ->
      currentValue = currentValue - 1
      if currentValue < 0
        clearInterval(interval)
        window.close()
      else
        clock.text(currentValue)
    , 1000)

    $(".countdown-stopper").on "click", ->
      clearInterval(interval)
