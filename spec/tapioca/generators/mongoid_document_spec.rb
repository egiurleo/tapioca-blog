# typed: false

require 'spec_helper'

class MongoidDocumentSpec < Minitest::Spec
  include Tapioca::Helpers::Test::Content
  include Tapioca::Helpers::Test::Template
  include Tapioca::Helpers::Test::Isolation
  extend T::Sig

  # icnlude Foo

  # compiler_file  '../../../sorbet/tapioca/generators/mongoid_document'
  # compiler_class { MongoidDocument }


  sig { returns(T::Array[String]) }
  def gathered_constants
    T.unsafe(self).subject.processable_constants.map(&:name).sort
  end

  def after_setup
    require_relative '../../../sorbet/tapioca/generators/mongoid_document'    # Get the class under test and initialize a new instance of it as the "subject"
  end

  subject do
    generator_for_names("MongoidDocument")
  end

  sig { params(names: String).returns(Tapioca::Compilers::Dsl::Base) }
  def generator_for_names(*names)
    raise "name is required" if names.empty?

    classes = names.map { |class_name| Object.const_get(class_name) }

    compiler = Tapioca::Compilers::DslCompiler.new(
      requested_constants: [],
      requested_generators: classes
    )

    T.must(compiler.generators.find { |generator| generator.class.name == names.first })
  end

  sig do
    params(
      constant_name: T.any(Symbol, String)
    ).returns(String)
  end
  def rbi_for(constant_name)
    # Make sure this is a constant that we can handle.
    assert_includes(gathered_constants, constant_name.to_s, <<~MSG)
      `#{constant_name}` is not processable by the generator.
    MSG

    file = RBI::File.new(strictness: "strong")

    constant = Object.const_get(constant_name)

    T.unsafe(self).subject.decorate(file.root, constant)

    file.transformed_string
  end

  sig { returns(T::Array[String]) }
  def generated_errors
    T.unsafe(self).subject.errors
  end

  sig { void }
  def assert_no_generated_errors
    T.unsafe(self).assert_empty(generated_errors)
  end

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
