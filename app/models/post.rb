# typed: true

class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String
  field :author, as: :a, type: String
  field :status, type: StringifiedSymbol
  field :settings, type: Hash
  field :array_field, type: Array
  field :count, type: Integer
  field :created_at, type: Time

  validates :count, numericality: true, allow_nil: false
end

post = Post.new(count: 1)
post.title = 'hello world!'
post.title
post.title?
post.id
post.status = :posted
post.status = 'posted'
post.status = 'posted'
post.status
post.settings = {password_protected: true}
post.a
post.title_changed?
post.title_change
post.title_was
post.reset_title!
