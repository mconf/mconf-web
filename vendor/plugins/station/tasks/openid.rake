namespace :station do
  namespace :openid do
    desc "OpenID store Garbage Collector"
    task :gc_ar_store => :environment do
      OpenIdActiveRecordStore.cleanup
    end

    namespace :identity_uris do
      desc "Reset OpenID identity URIs"
      task :reset => [ :clear, :create ]

      desc "Clear OpenID identity URIs"
      task :clear => :environment do
        ActiveRecord::Agent::OpenidServer.classes.each do |k|
          k.all.map(&:openid_ownings).map(&:destroy_all)
        end
      end

      desc "Create OpenID identity URIs"
      task :create => :environment do
        ActiveRecord::Agent::OpenidServer.classes.each do |k|
          k.all.map(&:create_openid_server_ownings)
        end
      end
    end
  end
end
