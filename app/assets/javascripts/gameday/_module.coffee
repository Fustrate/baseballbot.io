#= require_self
#= require_directory .
#= require_tree .

class window.Gameday
  @gdx = 'http://gd2.mlb.com/components/game/mlb'

  constructor: ->
    moment.updateLocale 'en',
      longDateFormat:
        LTS: 'h:mm:ss A'
        LT: 'h:mm A'
        L: 'M/D/YY'
        LL: 'MMMM D, YYYY'
        LLL: 'MMMM D, YYYY h:mm A'
        LLLL: 'dddd, MMMM D, YYYY h:mm A'
      calendar:
        lastDay: '[Yesterday at] LT'
        sameDay: '[Today at] LT'
        nextDay: '[Tomorrow at] LT'
        lastWeek: 'dddd [at] LT'
        nextWeek: '[next] dddd [at] LT'
        sameElse: 'L'

    @loadTodaysGames()

  loadTodaysGames: ->
    date = moment().format('[year_]YYYY[/month_]MM[/day_]DD')

    $.get("#{@constructor.gdx}/#{date}/miniscoreboard.xml")
    .done (response) ->
      root = $(response).find('games')

      root.find('game').each (n, game) ->
        console.log game
