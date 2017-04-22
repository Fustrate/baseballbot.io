class Gameday.GameCard
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

  constructor: (@game) ->
    @card = @constructor.gameCardTemplate.clone()

    @card
      .attr(id: @game.gameday_link)
      .data(gameCard: @)

    $('.home-team', @card).addClass @game.home_file_code
    $('.away-team', @card).addClass @game.away_file_code

    $('.home-team .name', @card).text @game.home_name_abbrev
    $('.away-team .name', @card).text @game.away_name_abbrev

  gameStatus: =>
    return @game.time if @game.status is 'Preview'

    return @game.status if @game.status in ['Pre-Game', 'Warmup', 'Delayed']

    return @game.status if @game.status isnt 'In Progress'

    sides = if @game.outs is '3' then ['Mid', 'End'] else ['Top', 'Bot']
    side = if @game.top_inning is 'Y' then sides[0] else sides[1]

    "#{side} #{@game.inning}"

    @game.status

  refreshInfo: =>
    $('.home-team .runs', @card).text @game.home_team_runs
    $('.away-team .runs', @card).text @game.away_team_runs

    $('.game-info', @card).text @gameStatus(@game)

  render: =>
    @refreshInfo()

    @card

  update: (@game) ->
    @refreshInfo()
