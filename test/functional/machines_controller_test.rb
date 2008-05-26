require File.dirname(__FILE__) + '/../test_helper'

class MachinesControllerTest < ActionController::TestCase
  include CMS::AuthenticationTestHelper
  
  fixtures   :machines_users, :machines, :participants, :users
  
  def test_my_mailer
    login_as("user_normal")
    post :my_mailer, :comment=>{:message=>'Quiero mas maquinas', :email=>'prueba@prueba.es'}
    assert_redirected_to :action=>'list_user_machines'
    assert flash[:notice].include?("Your message was successfully delivered to the SIR Administrator.")
  end
  
  def test_my_mailer_wrong
    login_as("user_normal")
    post :my_mailer, :comment=>{:message=>'Quiero mas maquinas', :email=>'malomalo'}
    assert_redirected_to :action=>'contact_mail'
    assert flash[:warning].include?("Your email address appears to be invalid")
  end
  
  def test_my_mailer_no_login
    
    post :my_mailer, :comment=>{:message=>'Quiero mas maquinas', :email=>'prueba@prueba.es'}
    assert_redirected_to :controller=>'sessions',:action=>'new'
  end
  
  def contact_mail
    login_as("user_normal")
    get :contact_mail
    assert_response :success
  end
  
  def contact_mail_no_login
    get :contact_mail
    assert_redirected_to :controller=>'sessions',:action=>'new'
    
  end
  
  def test_list_users_machines
    login_as("user_normal")
    get :list_user_machines
    assert_response :success
  end
  
  def test_get_file
    get :get_file
    assert_response :success
        
  end
  def test_manage_resources
    login_as("user_admin")
    get :manage_resources
    assert_response :success
    assert_not_nil assigns(:machines)
  end
  
  
  def test_manage_resources_not_admin
    login_as("user_normal")
    get :manage_resources
    assert_response :redirect
    assert flash[:notice].include?("Action not allowed.")
  end
  
  
  def test_add_resources_good
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :name_to_add => "nuevo", :nick_to_add => "nicknew"
    assert_response :redirect
    assert flash[:notice].include?("Resource successfully added")
  end
  
  
  def test_add_resources_with_blank_name
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :name_to_add => "", :nick_to_add => "nicknew"
    assert_response :success
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_add_resources_with_blank_nickname
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :name_to_add => "nuevo", :nick_to_add => ""
    assert_response :success
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_add_resources_with_no_name
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :nick_to_add => "nicknew"
    assert_response :success
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_add_resources_with_name_repeated
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :name_to_add => "azul", :nick_to_add => "nicknew"
    assert_response :redirect
    assert flash[:notice].include?("Name exist")
  end
  
  
  def test_add_resources_with_nickname_repeated
    login_as("user_admin")
    get :manage_resources, :myaction => "add", :name_to_add => "otttt", :nick_to_add => "macarra.dit.upm.es"
    assert_response :redirect
    assert flash[:notice].include?("Resource Full Name exist")
  end
  
  
  def test_edit_resources_good
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :name_to_add => "nuevo", :nick_to_add => "nicknew", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Resource edited successfully.")
  end
  
  
  def test_edit_resources_with_blank_name
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :name_to_add => "", :nick_to_add => "nicknew", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_edit_resources_with_blank_nickname
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :name_to_add => "nuevo", :nick_to_add => "", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_edit_resources_with_no_name
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :nick_to_add => "nicknew", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Nor name or nickname can be blank")
  end
  
  
  def test_edit_resources_with_name_repeated
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :name_to_add => "golpe", :nick_to_add => "nicknew", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Nickname already in use")
  end
  
  
  def test_edit_resources_with_nickname_repeated
    login_as("user_admin")
    get :manage_resources, :myaction => "edit", :name_to_add => "otttt", :nick_to_add => "golpe.dit.upm.es", :resource_id_to_edit =>"roja", :index_to_edit =>4
    assert_response :redirect
    assert flash[:notice].include?("Full name already in use")
  end
  
  
  def test_delete
    login_as("user_admin")
    get :manage_resources, :myaction => "delete",:resource_to_delete => "trapo"
    assert_response :redirect
    assert flash[:notice].include?("Resource deleted successfully.")
  end
  
  
  def test_assign_to_everybody
    login_as("user_admin")
    get :manage_resources, :myaction => "assign_to_all",:resource_id_to_edit => 6
    assert_response :redirect
    assert flash[:notice].include?("Resource assigned to everybody")
  end
  
end
