function change_space(){
	if (document.form.space_id.value == "0") {
		miloc = "/";
	}
	else {
		miloc = "/spaces/" + document.form.space_id.value;
	}
	document.location.href = miloc;
}

function esconde(Seccion)
  { 
    Element.hide(Seccion);
    Element.hide(Seccion+"bis");
    Element.hide(Seccion+"line");
  }
  
  function esconde_addtime()
  {
    //alert("entra con " + document.form_event.los_indices.value);
    numero = (document.form_event.los_indices.value-1);
    orden = "Element.hide('add_time"+numero+"');";
    document.form_event.los_indices.value = Number(document.form_event.los_indices.value) + 1;
    //alert("sale con " + document.form_event.los_indices.value);
    eval(orden);    
  }
  
  function remove_time(Seccion)
  {
    orden = "document.form_event.is_valid_"+Seccion+".value = false";
    eval(orden);
    esconde(Seccion);
  }
  
  
  function validate_password()
  {
  	if(document.form_event.event_password.value!=document.form_event.password2.value)
		alert("Password and Retype password aren't the same");
    else 
        document.form_event.submit();          
  }
  
  
  function validate_password_edit()
  {
  	if(document.form_event.event_password.value!=document.form_event.password2.value)
		alert("Password and Retype password aren't the same");
    else {
        //if there is a datetime that is being accomplished we have to send the information
        //alert(document.form_event.is_accomplising.value);
        if(document.form_event.is_accomplising != undefined)
        {
            //alert(document.form_event.hora_inicio_acc.value);
            document.form_event.hora_inicio_acc.value = datetime_now(document.form_event.is_accomplising.value);
        }        
        document.form_event.submit();
        }  
  }
  
  
  function validate_password_user()
  {
    if(document.form_add_user.userito_password1.value=='')
        alert("Password can't be blank");
  	else if(document.form_add_user.userito_password1.value!=document.form_add_user.user_password2.value)
		alert("Password and Retype password aren't the same");
    else
           document.form_add_user.submit();
  }
//no se usa
  //function that makes an ajax call and shows the summary of the event in the list view
  //function show_summary(event_id)
  {
    //I use /event/show_summa... because I need an absolute route
    //new Ajax.Updater('event_summary', '/show_summary/' + event_id, {method:'get', asynchronous:true, evalScripts:true}); return false;
    //document.location = "/show_summary/" + event_id
  }
  
  
  function delete_resource(index, nickname, name, id) {
    //new Ajax.Updater('is_valid_resource' + index, '/login/delete_resource?nickname='+nickname+"&name="+name, {asynchronous:true, evalScripts:true});
    //seccion = "resource" + index;
    //Element.hide(seccion);
    document.form_resource.myaction.value = "delete";
    document.form_resource.resource_to_delete.value = name;
    document.form_resource.submit();
  }  
  
  function assign_to_all(index, nickname, name, id) {
  	document.form_resource.myaction.value = "assign_to_all";
    document.form_resource.resource_id_to_edit.value = id;
	document.form_resource.submit();	
  }
  
  function edit_resource(index, nickname, name, id) {
    //test if the name and nickname are correctly written
    orden = "name = document.form_resource.resource_name"+index+".value";
    orden2 = "nickname = document.form_resource.resource_nickname"+index+".value";
    eval(orden);
    eval(orden2);
    if(name=="" || name==null)
        alert("Resource Nickname can't be blank");
    else if(nickname=="" || nickname==null)
        alert("Resource Full Name can't be blank");
    else if(name_is_repeated(index))
        alert("Resource Nickname repeated, please use another");
    else if(full_name_is_repeated(index))
        alert("Resource Full Name repeated, please use another");
    else
    {    
        document.form_resource.myaction.value = "edit";
        document.form_resource.index_to_edit.value = index+1;  //la cuenta empieza en 1 no en 0
        document.form_resource.resource_id_to_edit.value = id;
        document.form_resource.name_to_add.value = name;
        document.form_resource.nick_to_add.value = nickname;   
        document.form_resource.submit();
    }
  }
  
  function add_resource(index) {
    orden = "name = document.form_resource.resource_name"+index+".value";
    orden2 = "nickname = document.form_resource.resource_nickname"+index+".value";
    eval(orden);
    eval(orden2);
    if(name=="" || name==null)
        alert("Resource Nickname can't be blank");
    else if(nickname=="" || nickname==null)
        alert("Resource Full Name can't be blank");
    else if(name_edited_is_repeated(index))
        alert("Resource Nickname repeated, please use another");
    else if(full_name_is_repeated(index))
        alert("Resource Full Name repeated, please use another");
    else
    {
        //new Ajax.Updater('table_resources', '/login/add_resource?index='+index+'&nickname='+nickname+"&name="+name, {asynchronous:true, evalScripts:true});
        document.form_resource.myaction.value = "add";
        document.form_resource.name_to_add.value = name;
        document.form_resource.nick_to_add.value = nickname;        
        document.form_resource.submit();
    }
  }
  
  function name_is_repeated(index)
  {
    orden = "name = document.form_resource.resource_name"+index+".value";
    eval(orden);
    for(i=0; i<index;i++)
    {
        orden = "new_name = document.form_resource.resource_name"+i+".value";
        eval(orden);
        if(new_name==name)
          return true;
    }
  }
  
  function full_name_is_repeated(index)
  {
    orden = "full_name = document.form_resource.resource_nickname"+index+".value";
    eval(orden);
    for(i=0; i<index;i++)
    {
        orden = "new_full_name = document.form_resource.resource_nickname"+i+".value";
        eval(orden);
        if(new_full_name==full_name)
          return true;
    }
  }
    
  function name_edited_is_repeated(index)
  {
    orden = "name = document.form_resource.resource_name"+index+".value";
    eval(orden);
    for(i=0; i<document.form_resource.number_of_resources.value;i++)
    {
        if(i==index)
            break;
            
        orden = "new_name = document.form_resource.resource_name"+i+".value";
        eval(orden);
        if(new_name==name)
          return true;
    }
  }
