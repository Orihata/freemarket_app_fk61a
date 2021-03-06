class TransactionsController < ApplicationController
  before_action :need_login, :set_header

  def buying
    @item = Item.find(params[:item_id])
    @transaction = Transaction.new(item_id: @item.id, buyer_id: current_user.id, seller_id: @item.user.id)
    @point = 150
  end


  def create
    @transaction = Transaction.new(transaction_params)
    @item = Item.find(@transaction.item_id)
    render 'buying' and return unless @transaction.save
  end




private

  def transaction_params
    params.require(:transaction).permit(:item_id, :buyer_id, :seller_id)
  end

  def need_login
    redirect_to login_index_path unless user_signed_in?
  end

  def set_header
    @header_parents = Category.where(ancestry: nil)
  end

end
