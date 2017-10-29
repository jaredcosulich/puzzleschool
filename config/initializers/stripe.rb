Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'] || "pk_yNvkaRcCD7HxQFmMrFCSE4GPnZneb",
  :secret_key      => ENV['STRIPE_SECRET_KEY'] || "IOxi6eXrVyMXu2ykYgngnVXAsYnzElG3"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
