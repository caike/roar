require 'test_helper'

require "test_xml/mini_test"
require "roar/representer/json"

class JsonRepresenterTest < MiniTest::Spec
  class Order
    include Roar::Representer::JSON
    property :id
    property :pending
    attr_accessor :id, :pending
  end


  describe "JsonRepresenter" do
    before do
      @order = Order.new
    end


    describe "#to_json" do
      before do
        @order.id = 1
      end

      it "returns the serialized model" do
        assert_equal '{"id":1}', @order.to_json
      end

      it "is aliased by #serialize" do
        assert_equal '{"id":1}', @order.serialize
      end

      it "accepts :include and :exclude" do
        assert_equal '{}', @order.to_json(:exclude => [:id])
      end
    end

    describe "#from_json" do
      it "returns the deserialized model" do
        @order.from_json('{"id":1}')
        assert_equal 1, @order.id
      end

      it "is aliased by #deserialize" do
        @order.deserialize('{"id":1}')
        assert_equal 1, @order.id
      end

      it "works with a nil document" do
        assert @order.from_json(nil)
      end

      it "works with an empty document" do
        assert @order.from_json('')
      end

      it "accepts :include and :exclude" do
        @order.from_json('{"id":1}', :exclude => [:id])
        assert_equal nil, @order.id
      end
    end

    describe "JSON.from_json" do
      it "is aliased by #deserialize" do
        @order = Order.new.deserialize('{"id":1}')
        assert_equal 1, @order.id
      end
    end
  end
end

# test the generic roar+json HyperlinkRepresenter
class JsonHyperlinkRepresenterTest
  describe "API" do
    before do
      @link = Roar::Representer::Feature::Hypermedia::Hyperlink.new.extend(Roar::Representer::JSON::HyperlinkRepresenter).from_json(
        '{"rel":"self", "href":"http://roar.apotomo.de", "media":"web"}')
    end

    it "responds to #rel" do
      assert_equal "self", @link.rel
    end

    it "responds to #href" do
      assert_equal "http://roar.apotomo.de", @link.href
    end

    it "responds to #media" do
      assert_equal "web", @link.media
    end

    it "responds to #to_json" do
      assert_equal "{\"rel\":\"self\",\"href\":\"http://roar.apotomo.de\",\"media\":\"web\"}", @link.to_json
    end
  end
end

class JsonHypermediaTest
  describe "Hypermedia API" do
    before do
      @c = Class.new do
        include AttributesConstructor
        include Roar::Representer::JSON
        include Roar::Representer::Feature::Hypermedia
        attr_accessor :id, :self, :next

        property :id

        link :self do "http://self" end
        link :next do "http://next/#{id}" end
      end

      @r = @c.new
    end

    it "responds to #links" do
      @r.links.must_equal nil
    end

    it "extracts links from JSON" do
      r = @r.from_json('{"links":[{"rel":"self","href":"http://self"}]}')

      assert_equal 1, r.links.size
      link = r.links["self"]
      assert_equal(["self", "http://self"], [link.rel, link.href])
    end

    it "renders link: correctly in JSON" do
      assert_equal "{\"id\":1,\"links\":[{\"rel\":\"self\",\"href\":\"http://self\"},{\"rel\":\"next\",\"href\":\"http://next/1\"}]}", @c.new(:id => 1).to_json
    end

    it "doesn't render links when empty" do
      assert_equal("{\"links\":[]}", Class.new do
        include Roar::Representer::JSON
        include Roar::Representer::Feature::Hypermedia

        link :self do nil end
        link :next do false end
      end.new.to_json)
    end

  end
end

