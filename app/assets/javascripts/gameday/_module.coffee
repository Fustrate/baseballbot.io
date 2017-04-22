#= require_self
#= require_directory .
#= require_tree .

class window.Gameday
  @gdx = 'http://gd2.mlb.com/components/game/mlb'

  @gameCardTemplate: $ '''
    <div class="game-card">
      <div class="away-team">
        <div class="runs"></div>
        <div class="name"></div>
      </div>
      <div class="home-team">
        <div class="name"></div>
        <div class="runs"></div>
      </div>
      <div class="game-info"></div>
    </div>'''

  constructor: ->
    @loadTodaysGames()

  loadTodaysGames: ->
    date = moment().format('[year_]YYYY[/month_]MM[/day_]DD')

    $.get("#{@constructor.gdx}/#{date}/miniscoreboard.xml")
    .done (response) =>
      root = $(response).find('games')

      cards = for element in root.find('game')
        game = $ element

        card = @constructor.gameCardTemplate.clone()

        $('.home-team', card).addClass game.attr('home_file_code')
        $('.away-team', card).addClass game.attr('away_file_code')

        $('.home-team .name', card).text game.attr('home_name_abbrev')
        $('.away-team .name', card).text game.attr('away_name_abbrev')
        $('.home-team .runs', card).text game.attr('home_team_runs')
        $('.away-team .runs', card).text game.attr('away_team_runs')

        $('.game-info', card).text game.attr('time')

        card

      $('.game-cards').empty().append cards

      $('.loading').hide()
