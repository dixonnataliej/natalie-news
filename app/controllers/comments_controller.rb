class CommentsController < ApplicationController
  include Pagy::Backend
  before_action :set_article, only: %i[ show edit create update destroy ]
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [ :show ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  # GET /articles/1/comments/1
  def show
  end

  def edit
  end

  def create
    @comment = @article.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @article, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { redirect_to @article, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @article, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1/comments/1
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to @article, status: :see_other, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def reply
    @article = Article.find(params[:article_id])
    @parent_comment = Comment.find(params[:id])
    @comment = Comment.new(parent_id: @parent_comment.id)

    render partial: "comments/form", locals: { article: @article, comment: @comment, form_class: "reply" }
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params.expect(:id))
    end

    def set_article
      @article = Article.find(params[:article_id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:body, :parent_id)
    end

    def authorize_user!
      unless @comment.user == current_user
        redirect_to articles_path, alert: "You are not authorized to do that."
      end
    end
end
