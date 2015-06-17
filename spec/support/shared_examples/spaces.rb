# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Check that @spaces_examples is assigned properly.
#
# Arguments:
#   do_action: the action to be called
#
# Example:
#   let(:do_action) { get :new }
#   it_should_behave_like "assigns @spaces_examples"
#
shared_examples_for "assigns @spaces_examples" do
  it "assigns the variable" do
    do_action
    should assign_to(:spaces_examples)
  end

  context "includes all types of spaces" do
    before {
      @s1 = FactoryGirl.create(:space)
      @s2 = FactoryGirl.create(:public_space)
      @s3 = FactoryGirl.create(:private_space)
    }
    before(:each) { do_action }
    it { assigns(:spaces_examples).should be_include(@s1) }
    it { assigns(:spaces_examples).should be_include(@s2) }
    it { assigns(:spaces_examples).should be_include(@s3) }
  end

  context "limits to 3 spaces" do
    before { 5.times { FactoryGirl.create(:space) } }
    before(:each) { do_action }
    it { assigns(:spaces_examples).count.should be(3) }
  end
end
