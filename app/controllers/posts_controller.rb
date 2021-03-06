class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy, :readed]

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "投稿しました"
      redirect_to @post
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def index
    @posts = Post.page(params[:page]).per(60)
  end

  def show
    store_location
    readed if params[:notification_id]
    @post = Post.find(params[:id])
    @user = @post.user
    @comments = @post.comments.all
    @comment = Comment.new
    @likes = @post.likes.all
    @like = Like.new
  end

  def modal
    @post = Post.find(params[:id])
    @comments = @post.comments.all
  end

  def destroy
    post = Post.find(params[:id])
    post.delete
    flash[:success] = "削除しました"
    redirect_to root_url
  end

  def readed
    current_user.notifications.where(id: params[:notification_id]).update(already: true)
  end

  private

    def post_params
      params.require(:post).permit(:content, { pictures: [] })
    end
end
