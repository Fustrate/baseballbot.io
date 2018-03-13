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
      <div class="game-info">
        <span class="status"></span>
        <span class="outs"></span>
        <div class="runners">
          <div class="first"></div>
          <div class="second"></div>
          <div class="third"></div>
        </div>
      </div>
    </div>'''

  constructor: (@game) ->
    @card = @constructor.gameCardTemplate.clone()
      .attr(id: @game.gameday_link)
      .data(gameCard: @)

    $('.home-team', @card).addClass @game.home_file_code
    $('.away-team', @card).addClass @game.away_file_code

    $('.home-team .name', @card).text @game.home_name_abbrev
    $('.away-team .name', @card).text @game.away_name_abbrev

  # 0: Bases empty
  # 1: Runner on 1st
  # 2: Runner on 2nd
  # 3: Runner on 3rd
  # 4: Runners on 1st and 2nd
  # 5: Runners on 1st and 3rd
  # 6: Runners on 2nd and 3rd
  # 7: Bases loaded
  runners: =>
    $('.runners', @card).toggle @inProgress()

    return unless @inProgress()

    index = parseInt @game.runner_on_base_status, 10

    $('.first', @card).toggleClass 'runner', (index in [1, 4, 5, 7])
    $('.second', @card).toggleClass 'runner', (index in [2, 4, 6, 7])
    $('.third', @card).toggleClass 'runner', (index in [3, 5, 6, 7])

  outs: =>
    $('.outs', @card).toggle @inProgress()

    return unless @inProgress()

    outs = parseInt @game.outs, 10

    elements = if outs < 3
      $('<span class="out"></span>') for n in [0...outs]
    else
      []

    $('.outs', @card).empty().append(elements)

  inProgress: =>
    @game.status in ['In Progress', 'Manager Challenge']

  pregame: =>
    @game.status in ['Pre-Game', 'Warmup', 'Delayed Start', 'Scheduled']

  gameStatus: =>
    return @game.time if @game.status is 'Preview'

    return "#{@game.time} - #{@game.status}" if @pregame()

    return @game.status if not @inProgress()

    sides = if @game.outs is '3' then ['Mid', 'End'] else ['Top', 'Bot']
    side = if @game.top_inning is 'Y' then sides[0] else sides[1]

    "#{side} #{@game.inning}"

  refreshInfo: =>
    @outs()
    @runners()

    $('.home-team .runs', @card).text @game.home_team_runs
    $('.away-team .runs', @card).text @game.away_team_runs

    $('.status', @card).text @gameStatus(@game)

  render: =>
    @refreshInfo()

    @card

  update: (@game) ->
    @refreshInfo()
