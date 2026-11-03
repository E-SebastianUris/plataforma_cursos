Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      /\Ahttp:\/\/localhost(:\d+)?\z/,
      /\Ahttps:\/\/[a-z0-9\-]+(\.vercel\.app|\.onrender\.com)\z/i,
      *ENV.fetch("FRONT_ORIGIN", "*").split(",").map(&:strip)
    )

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ]
  end
end
