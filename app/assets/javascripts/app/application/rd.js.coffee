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

    else if name is "subscription"
      form = $('#new_subscription')
      email = form.data('rd-email')
      name = form.data('rd-name')
      form.on 'submit', (ev) ->
        data_array = [
          { name: 'token_rdstation', value: mconf.RDToken },
          { name: 'identificador', value: 'nova-assinatura' },
          { name: 'email', value: email },
          { name: 'nome', value: name }
        ]
        RdIntegration.post(data_array)
