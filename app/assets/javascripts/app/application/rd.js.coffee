# Integration with RD Station
class mconf.RD

  @setupForm: (name) ->
    if name is "registration"
      meus_campos =
        'user[email]': 'email'
        'user[username]': 'nome-usuario'
        'user[profile_attributes][full_name]': 'nome'
      options = { fieldMapping: meus_campos }
      RdIntegration.integrate(mconf.RDToken, 'nova-conta', options);
