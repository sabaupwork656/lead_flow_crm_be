class JsonWebToken
  SECRET = Rails.application.credentials.secret_key_base || ENV.fetch("SECRET_KEY_BASE", "development-secret")

  def self.encode(payload, exp = 24.hours.from_now)
    JWT.encode(payload.merge(exp: exp.to_i), SECRET)
  end

  def self.decode(token)
    JWT.decode(token, SECRET).first
  end
end
