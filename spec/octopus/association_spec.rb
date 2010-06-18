require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Octopus::Association do
  describe "when you have a 1 x 1 relationship" do
    before(:each) do
      @computer_brazil = Computer.using(:brazil).create!(:name => "Computer Brazil")
      @computer_master = Computer.create!(:name => "Computer Brazil")
      @keyboard_brazil = Keyboard.using(:brazil).create!(:name => "Keyboard Brazil", :computer => @computer_brazil)
      @keyboard_master = Keyboard.create!(:name => "Keyboard Master", :computer => @computer_master)
    end    

    it "should find the models" do
      @keyboard_master.computer.should == @computer_master
      @keyboard_brazil.computer.should == @computer_brazil
    end
    
    it "should read correctly the relationed model" do
      new_computer_brazil = Computer.using(:brazil).create!(:name => "New Computer Brazil")
      new_computer_master = Computer.create!(:name => "New Computer Brazil")
      @keyboard_master.computer = new_computer_brazil
      @keyboard_master.save()
      @keyboard_master.reload
      @keyboard_master.computer_id.should ==  new_computer_brazil.id
      @keyboard_master.computer.should ==  new_computer_brazil
      new_computer_brazil.save()
      new_computer_brazil.reload      
      new_computer_brazil.keyboard.should == @keyboard_master
    end
  end

  describe "when you have a N x N reliationship" do
    it "should be implemented" do
      pending()          
    end
  end

  describe "when you have has_many through" do
    it "should be implemented" do
      pending()      
    end
  end

  describe "when you have a 1 x N relationship" do
    before(:each) do
      @brazil_client = Client.using(:brazil).create!(:name => "Brazil Client")
      @master_client = Client.create!(:name => "Master Client")
      @item_brazil = Item.using(:brazil).create!(:name => "Brazil Item", :client => @brazil_client)
      @item_master = Item.create!(:name => "Master Item", :client => @master_client)
      @brazil_client = Client.using(:brazil).find_by_name("Brazil Client")
      Client.using(:master).create!(:name => "teste")        
    end

    it "should find all models in the specified shard" do
      @brazil_client.item_ids.should == [@item_brazil.id]
      @brazil_client.items().should == [@item_brazil]
    end

    it "should finds the client that the item belongs" do
      @item_brazil.client.should == @brazil_client
    end

    it "should update the attribute for the item" do
      new_brazil_client = Client.using(:brazil).create!(:name => "new Client")
      @item_brazil.client = new_brazil_client
      @item_brazil.client.should == new_brazil_client
      @item_brazil.save()
      @item_brazil.reload
      @item_brazil.client_id.should == new_brazil_client.id
      @item_brazil.client().should == new_brazil_client
    end

    it "should works for build method" do
      item2 = Item.using(:brazil).create!(:name => "Brazil Item")
      c = item2.create_client(:name => "new Client")
      c.save()
      item2.save()
      item2.client.should == c
      c.items().should == [item2]
    end

    describe "it should works when using" do
      before(:each) do
        @item_brazil_2 = Item.using(:brazil).create!(:name => "Brazil Item 2")
        @brazil_client.items.to_set.should == [@item_brazil].to_set 
      end

      it "update_attributes" do
        @brazil_client.update_attributes(:item_ids => [@item_brazil_2.id, @item_brazil.id])
        @brazil_client.items.to_set.should == [@item_brazil, @item_brazil_2].to_set
      end

      it "update_attribute" do
        @brazil_client.update_attribute(:item_ids, [@item_brazil_2.id, @item_brazil.id])
        @brazil_client.items.to_set.should == [@item_brazil, @item_brazil_2].to_set
      end

      it "<<" do
        @brazil_client.items << @item_brazil_2
        @brazil_client.items.to_set.should == [@item_brazil, @item_brazil_2].to_set
      end

      it "build" do
        item = @brazil_client.items.build(:name => "Builded Item")
        item.save()
        @brazil_client.items.to_set.should == [@item_brazil, item].to_set
      end

      it "create" do
        item = @brazil_client.items.create(:name => "Builded Item")
        @brazil_client.items.to_set.should == [@item_brazil, item].to_set          
      end

      it "count" do
        @brazil_client.items.count.should == 1
        item = @brazil_client.items.create(:name => "Builded Item")
        @brazil_client.items.count.should == 2
      end

      it "size" do
        @brazil_client.items.size.should == 1          
        item = @brazil_client.items.create(:name => "Builded Item")
        @brazil_client.items.size.should == 2          
      end

      it "create!" do
        item = @brazil_client.items.create!(:name => "Builded Item")
        @brazil_client.items.to_set.should == [@item_brazil, item].to_set                    
      end

      it "length" do
        @brazil_client.items.length.should == 1          
        item = @brazil_client.items.create(:name => "Builded Item")
        @brazil_client.items.length.should == 2                    
      end

      it "empty?" do
        @brazil_client.items.empty?.should be_false
        c = Client.create!(:name => "Client1")
        c.items.empty?.should be_true
      end

      it "delete" do
        @brazil_client.items.empty?.should be_false
        @brazil_client.items.delete(@item_brazil)
        @brazil_client.reload
        @item_brazil.reload
        @item_brazil.client.should be_nil
        @brazil_client.items.should == []
        @brazil_client.items.empty?.should be_true
      end

      it "delete_all" do
        @brazil_client.items.empty?.should be_false     
        @brazil_client.items.delete_all                
        @brazil_client.items.empty?.should be_true
      end

      it "destroy_all" do
        @brazil_client.items.empty?.should be_false     
        @brazil_client.items.destroy_all                
        @brazil_client.items.empty?.should be_true
      end

      it "find" do
        @brazil_client.items.find(:first).should == @item_brazil
        @brazil_client.items.destroy_all                
        @brazil_client.items.find(:first).should be_nil
      end

      it "exists?" do
        @brazil_client.items.exists?(@item_brazil).should be_true
        @brazil_client.items.destroy_all                
        @brazil_client.items.exists?(@item_brazil).should be_false     
      end

      it "uniq" do
        @brazil_client.items.uniq.should == [@item_brazil]                
      end        

      it "clear" do
        @brazil_client.items.empty?.should be_false     
        @brazil_client.items.clear                
        @brazil_client.items.empty?.should be_true          
      end
    end
  end
end