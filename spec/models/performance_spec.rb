require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Performance do
  before do
    @space = Factory(:space)
  end

  it "should not update Performance when there is only one Admin" do
    @admin_performance = Factory(:admin_performance, :stage => @space)

    @space.users.size.should == 1

    @admin_performance.role_id = @space.class.roles.sort.first.id
    assert ! @admin_performance.valid?
  end

  it "should not delete Performance when there is only one Admin" do
    @admin_performance = Factory(:admin_performance, :stage => @space)

    @space.users.size.should == 1

    pending "bug #419"
    assert_no_difference @space.users.count.to_s do
      @admin_performance.destroy.should be_false
    end
  end
end

