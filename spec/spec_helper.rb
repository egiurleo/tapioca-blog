# typed: strict
# frozen_string_literal: true

require "tapioca/internal"
require "minitest/autorun"
require "minitest/spec"
require "minitest/hooks/default"
require "byebug"

require "tapioca/helpers/test/content"
require "tapioca/helpers/test/template"
require "tapioca/helpers/test/isolation"
# require_relative "./dsl_spec_helper"

module Minitest
  class Test
    extend T::Sig

    Minitest::Test.make_my_diffs_pretty!
  end
end
