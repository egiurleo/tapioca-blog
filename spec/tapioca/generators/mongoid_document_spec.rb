# typed: false

require_relative '../../spec_helper'
require_relative '../../../sorbet/tapioca/generators/mongoid_document'

class MongoidDocumentSpec < DslSpec
  describe('#initialize') do
    after(:each) do
      T.unsafe(self).assert_no_generated_errors
    end

    it('gathers one constants if there are no classes using Mongoid::Document') do
      assert_equal(["Mongoid::GlobalDiscriminatorKeyAssignment::InvalidFieldHost"], gathered_constants)
    end

    it("gathers only classes including Mongoid::Document") do
      add_ruby_file("shop.rb", <<~RUBY)
        class Shop
        end

        class ShopWithDocument
          include Mongoid::Document
        end
      RUBY
      assert_equal(
        [
          "Mongoid::GlobalDiscriminatorKeyAssignment::InvalidFieldHost",
          "ShopWithDocument"
        ],
        gathered_constants
      )
    end
  end


  describe("#decorate") do
    after(:each) do
      T.unsafe(self).assert_no_generated_errors
    end

    it("generates signatures for id and _id if there are no fields in the class") do
      add_ruby_file("shop.rb", <<~RUBY)
        class Shop
          include Mongoid::Document
        end
      RUBY

      expected = <<~RBI
        # typed: strong

        class Shop
          sig { returns(T.nilable(BSON::ObjectId)) }
          def _id; end

          sig { params(val: T.nilable(BSON::ObjectId)).returns(T.nilable(BSON::ObjectId)) }
          def _id=(val); end

          sig { returns(T::Boolean) }
          def _id?; end

          sig { returns(T::Array[T.nilable(BSON::ObjectId)]) }
          def _id_change; end

          sig { returns(T::Boolean) }
          def _id_changed?; end

          sig { returns(T.nilable(BSON::ObjectId)) }
          def _id_was; end

          sig { returns(T.nilable(BSON::ObjectId)) }
          def id; end

          sig { params(val: T.nilable(BSON::ObjectId)).returns(T.nilable(BSON::ObjectId)) }
          def id=(val); end

          sig { returns(T::Boolean) }
          def id?; end

          sig { returns(T::Array[T.nilable(BSON::ObjectId)]) }
          def id_change; end

          sig { returns(T::Boolean) }
          def id_changed?; end

          sig { returns(T.nilable(BSON::ObjectId)) }
          def id_was; end

          sig { returns(T.nilable(BSON::ObjectId)) }
          def reset__id!; end

          sig { returns(T.nilable(BSON::ObjectId)) }
          def reset_id!; end
        end
      RBI

      assert_equal(expected, rbi_for(:Shop))
    end
  end
end
