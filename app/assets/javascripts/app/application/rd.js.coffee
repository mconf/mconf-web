# Integration with RD Station
class mconf.RD

  @setupForm: (name) ->
    if name is "registration"
      meus_campos =
        'user[email]': 'email'
        'user[username]': 'nome-usuario'
        'user[profile_attributes][full_name]': 'nome'
      options = { fieldMapping: meus_campos }
      RdIntegration.integrate('c7e7748a2bd3407b8c131725ac1e2650', 'nova-conta', options);
