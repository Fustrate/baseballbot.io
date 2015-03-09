def reddit
  @reddit ||= Redd.it :web,
                      ENV['REDDIT_CLIENT_ID'],
                      ENV['REDDIT_SECRET'],
                      ENV['REDDIT_REDIRECT_URI']
end
