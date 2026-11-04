Rails.application.config.after_initialize do
  if defined?(Rails::Server) && ActiveRecord::Base.connection.table_exists?("users") && User.none?
    Rails.logger.info "[Boot] No se encontraron usuarios. Ejecutando db/seeds.rb automáticamente..."
    Rails.application.load_seed
  end
rescue StandardError => e
  Rails.logger.warn "[Boot] No se pudo ejecutar auto-seed: #{e.message}"
end

