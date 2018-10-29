#= require_self
#= require_directory .
#= require_tree .

class window.Baseballbot extends Fustrate
  constructor: ->
    super()

    moment.tz.setDefault moment.tz.guess()
