class FrontendController < EmberCli::EmberController
  after_action :allow_iframes, only: [:index]

private

  def allow_iframes
    response.headers.except! 'X-Frame-Options'
  end
end
