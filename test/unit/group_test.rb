require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :users, :roles
  
  def test_new_space_creates_new_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    assert_not_nil(Group.find_by_name("prueba"))
  end
  
  def test_create_space_with_blank_space_in_name_creates_valid_group_name
    @space = Space.create(:name => "prueba nueva", :description => "prueba")
    assert_not_nil(Group.find_by_name("pruebanueva"))
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
  end
  
  def test_new_user_roled_user_adds_to_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:user), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user), "does not add an user roled user to the main group when added to the space") 
  end
  
  def test_new_invited_roled_user_does_not_add_to_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:invited), :container => @space)
    group = Group.find_by_name("prueba")
    assert(!group.users.include?(@user), "it shouldn't add an invited roled user to the main group when added to the space")  
  end
  
  def test_delete_admin_roled_user_erases_from_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:admin), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user))
    @perfor.destroy
    assert(!group.users.include?(@user), "does not delete the admin roled user from the main group when deleted from the space")
  end
  
  def test_delete_user_roled_user_erases_from_group
    @space = Space.create(:name => "prueba", :description => "prueba")
    @user = users(:user_alfredo)
    @perfor = Performance.create(:agent => @user, :role => roles(:user), :container => @space)
    group = Group.find_by_name("prueba")
    assert(group.users.include?(@user))
    @perfor.destroy
    assert(!group.users.include?(@user), "does not delete the user roled user from the main group when deleted from the space")    
  end
  
  def test_main_group_cannot_be_editable
    assert(false, "TODO")
  end
  
end
