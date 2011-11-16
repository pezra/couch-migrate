shared_examples_for "a_persisted_list" do
  subject { raise "subject must return a new instance" }

  it "starts off with an empty value/list" do
    subject.get.should == []
  end

  it "can set values" do
    arr = [1,2,3]
    subject.set(arr).get.should == arr
  end

  it "can append values" do
    arr = [1,2,3]
    more = [4,5]
    expected = [1,2,3,4,5]

    subject.set(arr).add(more)
    subject.get.should == expected
  end

  it "can remove values" do
    arr = [1,2,3]
    remove = [2,3]
    expected = [1]

    subject.set(arr).remove(remove)
    subject.get.should == expected
  end

  it "can be reset" do
    subject.set([1,2,3]).reset
    subject.get.should == []
  end

  it "is chainable" do
    subject.set([1]).add([2]).get.should == [1,2]
    subject.set([1]).add([2]).reset.get.should == []
  end

end

