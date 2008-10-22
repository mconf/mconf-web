require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users, :roles
  
  def test_new_space_creates_new_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    assert_not_nil(Group.find_by_name("prueba"))
    Group.find_by_name("prueba").destroy
  end
  
  def test_create_space_with_blank_space_in_name_creates_valid_group_name
    @space = Space.create(:name => "prueba nueva", :description => "prueba")
    assert_not_nil(Group.find_by_name("pruebanueva"))
    Group.find_by_name("pruebanueva").destroy
  end
  
  def test_deleting_space_deletes_groups
    @space = Space.create(:name => "prueba", :description => "prueba")
    @space.destroy
    assert_nil(Group.find_by_name("prueba"))
  end
  
  def test_new_admin_roled_user_adds_to_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:admin), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user), "does not add an admin roled user to the main group when added to the space")
    group.destroy
  end
  
  def test_new_user_roled_user_adds_to_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:user), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user), "does not add an user roled user to the main group when added to the space") 
    group.destroy
  end
  
  def test_new_invited_roled_user_does_not_add_to_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:invited), :container => @space)
    group = Group.find_by_name("prueba")
    assert(!group.users.include?(@user), "it shouldn't add an invited roled user to the main group when added to the space")
    group.destroy
  end
  
  def test_delete_admin_roled_user_erases_from_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:admin), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user))
    @perfor.destroy
    assert(!group.users.include?(@user), "does not delete the admin roled user from the main group when deleted from the space")
    group.destroy
  end
  
  def test_delete_user_roled_user_erases_from_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:user), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user))
    @perfor.destroy
    assert(!group.users.include?(@user), "does not delete the user roled user from the main group when deleted from the space")
    group.destroy
  end
  
  def test_main_group_cannot_be_editable
    #TODO
  end

# A continuación hay varios tests que sólo deben ser ejecutados en caso de no funcionar las listas de correo
# puesto que ejecutan comandos en la máquina de jungla  

=begin
  
  def test_creating_group_should_update_jungla
    @group = Group.create(:name => "lista")
    assert(`ssh ebarra@jungla.dit.upm.es ls /users/jungla/ebarra/listas/automaticas/vcc-ACTUALIZAR`.any?, 
    "No se crea un fichero de vcc-ACTUALIZAR")
    assert(`ssh ebarra@jungla.dit.upm.es ls /users/jungla/ebarra/listas/automaticas/vcc-lista.txt`.any?, 
    "No se crea un fichero de vcc-lista")
    @group.destroy
  end
  
  def test_deleting_group_should_update_jungla
    @group = Group.create(:name => "lista")
    @group.destroy
    assert(!`ssh ebarra@jungla.dit.upm.es ls /users/jungla/ebarra/listas/automaticas/vcc-lista.txt 2>/dev/null`.any?, 
    "No se borra el fichero de vcc-lista después de borrar el grupo")
  end
=end
  
  def test_updating_group_should_update_jungla
    @group = Group.create(:name => "lista")
    @group.update_attributes(:name => "lista2")
    assert(`ssh ebarra@jungla.dit.upm.es ls /users/jungla/ebarra/listas/automaticas/vcc-lista2.txt`.any?, 
    "No se crea un fichero de vcc-lista2 cambiado")
    @group.destroy
  end



end
