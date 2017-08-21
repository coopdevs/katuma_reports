class RedirectToOFNFailure < Devise::FailureApp

  # Overrides the URL we redirect to when the request is not authorized. This
  # will happen, for instance, when the user logs out from the main OFN app.
  #
  # You must provide the $OFN_MAIN_APP_BASE_URL env var as follows:
  #
  #   export OFN_MAIN_APP_BASE_URL="http://localhost:3000"
  def redirect_url
    URI.join(ENV.fetch('OFN_MAIN_APP_BASE_URL'), 'login').to_s
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
