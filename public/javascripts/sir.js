function generate_attach(number){
	
	 var diva = document.getElementById('attachs');
	 var newdiv = document.createElement('div');
	 var num1up = number + 1;
     var last_post = document.getElementById('last_post');
	 last_post.value = num1up;
	 newdiv.setAttribute('id',"attachs"+number ); 
	 newdiv.setAttribute('name',"attachs"+number ); 
	 newdiv.innerHTML = "<p> <label for='attachment'> Upload Attachment: </label> <input id='attachment" + number +"_uploaded_data' name='attachment" + number +  "[uploaded_data]' size='30' type='file' '/> <a onclick='remove_attach(" + number + ") ; return false;' href='#'> Remove</a></p>"; 
	 diva.appendChild(newdiv);
	 var span_attach = document.getElementById('addAnother');
	 var parent_node_span = span_attach.parentNode;
	 parent_node_span.removeChild(span_attach);
	 var add_another = document.createElement('div');
	 add_another.setAttribute('id',"addAnother" ); 
	 add_another.innerHTML = "<a onclick='generate_attach(" + num1up + ") ; return false;' href='#'> add another</a>";
	 diva.appendChild(add_another);

}

function remove_attach(number){
	 var remove_div = document.getElementById('attachs'+number);
	 var parent_node_span = remove_div.parentNode;
	 parent_node_span.removeChild(remove_div);
	 
}

function hide_logotype(name){
	 var answer = confirm("This action will delete the current "+ name + " after clicking the update button.\n Are you sure?")
	 if(answer){
	 var remove_div = document.getElementById('image_logo');
	 var parent_node_span = remove_div.parentNode;
	 parent_node_span.removeChild(remove_div);
	 var hidden = document.getElementById('delete_thumbnail');
	 hidden.value = true;	
	 }
	 
}

function hide_attach(entry_id, attachment_id){
	 var remove_div = document.getElementById('attachment_'+attachment_id);
	 var parent_node_span = remove_div.parentNode;
	 parent_node_span.removeChild(remove_div);
	 var hidden = document.getElementById(entry_id);
	 hidden.value = false;
	 
	 
}

function change_space(){
	miloc = "/spaces/" + document.form.space_id.value;
	document.location.href = miloc;
}

function change_per_page(space_name){
	miloc = "/spaces/" + space_name + "/articles?expanded=false&per_page=" + document.get_page.page_id.value;
	document.location.href = miloc;
}
function esconde(Seccion)
  { 
    Element.hide(Seccion);
    Element.hide(Seccion+"bis");
    Element.hide(Seccion+"line");
	Element.hide("add_"+Seccion);
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
    document.getElementById("is_valid_"+Seccion).value = false;    
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
        document.form_resource.action.value = "/machines/"+id;
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
  
  function remove_from_group(){
		var selec = document.getElementById("group_users_id");
		while (selec.selectedIndex != -1) {					
				selec.options[selec.selectedIndex] = null;
		}
	}
	
	function add_to_the_group(){ 
		var ob = document.getElementById("users_id");
		while (ob.selectedIndex != -1) {
				hijo = ob.options[ob.selectedIndex];
				if(already_in_the_group(hijo.text))
				{
					alert("The user " + hijo.text + " is already in the group");
					return;
				}
				document.getElementById("group_users_id").appendChild(new Option(hijo.text,hijo.value));				
				ob.options[ob.selectedIndex].selected = false; 
		}		
	}
	
	function already_in_the_group(hijo){
		len =	document.getElementById("group_users_id").length;
		for(i=0;i<len;i++){
			hijo_del_grupo = document.getElementById("group_users_id").options[i].text;
			if(hijo_del_grupo==hijo)
				return true;
		}
		return false;
	}
	
	function selectAllOptions()
	{
	  var selObj = document.getElementById("group_users_id");
	  for (var i=0; i<selObj.options.length; i++) {
	    selObj.options[i].selected = true;
	  }
	}

