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

  elementAttributes: (element) ->
    obj = {}

    for attribute in element.attributes
      obj[attribute.name] = attribute.value if attribute.specified

    obj

  loadTodaysGames: ->
    date = moment().format('[year_]YYYY[/month_]MM[/day_]DD')

    $.get("#{@constructor.gdx}/#{date}/miniscoreboard.xml")
    .done (response) =>
      root = $(response).find('games')

      cards = for element in root.find('game')
        game = @elementAttributes element

        card = @constructor.gameCardTemplate.clone()

        $('.home-team', card).addClass game.home_file_code
        $('.away-team', card).addClass game.away_file_code

        $('.home-team .name', card).text game.home_name_abbrev
        $('.away-team .name', card).text game.away_name_abbrev
        $('.home-team .runs', card).text game.home_team_runs
        $('.away-team .runs', card).text game.away_team_runs

        $('.game-info', card).text game.time

        card

      spacer = document.createElement('div')
      spacer.className = 'card-spacer'

      cards.push spacer.cloneNode() for n in [0..3]

      $('.game-cards').empty().append(cards)

      $('.loading').hide()
