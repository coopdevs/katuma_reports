class RedirectToOFNFailure < Devise::FailureApp
  def redirect_url
    'http://localhost:3000'
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
