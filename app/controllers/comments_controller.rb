class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    commentable = commentable_type.constantize.find(commentable_id)
    @comment = Comment.build_from(commentable, current_user.id, body, subject)

    respond_to do |format|
      if @comment.save
        #byebug
        make_child_comment
        format.html  { redirect_to(:back, :notice => 'Comment was successfully added.') }
      else
        format.html  { render :action => "new" }
      end
    end
  end
  #
  # def upvote
  #   @comment = Comment.find(params[:id])
  #   @comment.upvote_by current_user
  #   redirect_to :back
  # end
  #
  # def downvote
  #   @comment = Comment.find(params[:id])
  #   @comment.downvote_by current_user
  #   redirect_to :back
  # end

  def upvote
    @debat = Comment.find(params[:id])
    @debat.upvote_by current_user
    respond_to do |format|
      format.html {redirect_to :back }
      format.json { render json: { count: @debat.liked_count } }
      format.js   { render :layout => false }
    end
  end

  def downvote
    @debat = Comment.find(params[:id])
    @debat.downvote_by current_user
    respond_to do |format|
      format.html {redirect_to :back }
      format.json { render json: { count: @debat.disliked_count } }
      format.js   { render :layout => false }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :subject, :commentable_id, :commentable_type, :comment_id)
  end

  def commentable_type
    comment_params[:commentable_type]
  end

  def commentable_id
    comment_params[:commentable_id]
  end

  def comment_id
    comment_params[:comment_id]
  end

  def body
    comment_params[:body]
  end

  def subject
    comment_params[:subject]
  end

  def make_child_comment
    return "" if comment_id.blank?

    parent_comment = Comment.find comment_id
    @comment.move_to_child_of(parent_comment)
  end

end  