#= require_self
#= require_directory .
#= require_tree .

class window.Gameday
  @gdx = 'http://gdx.mlb.com/components/game/mlb'

  constructor: ->
    @date = moment()

    @_reloadGameInfo(@date, @createGameCards)

    window.setInterval =>
      @_reloadGameInfo(@date, @updateGameCards)
    , 15000

  createGameCards: (gameNodes) =>
    cards = for element in gameNodes
      new Gameday.GameCard(@_elementAttributes element)

    nodes = (card.render() for card in cards)

    spacer = document.createElement('div')
    spacer.className = 'card-spacer'

    nodes.push spacer.cloneNode() for n in [0..3]

    $('.game-cards').empty().append(nodes)

    $('.loading').hide()

  updateGameCards: (gameNodes) =>
    for element in gameNodes
      attributes = @_elementAttributes element

      $("##{attributes.gameday_link}")
        .data('game-card')
        .update(attributes)

  _elementAttributes: (element) ->
    obj = {}

    for attribute in element.attributes
      obj[attribute.name] = attribute.value if attribute.specified

    obj

  _reloadGameInfo: (date, onLoad = ->) ->
    date_folder = date.format('[year_]YYYY[/month_]MM[/day_]DD')

    $.get("#{@constructor.gdx}/#{date_folder}/miniscoreboard.xml")
    .done (response) ->
      onLoad $(response).find('games game')
