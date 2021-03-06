class SellController < ApplicationController
  before_action :need_login, :set_header

  def index
    @items = Item.limit(10).order('created_at DESC')
    @category = Category.all
  end

  def new
    @item = Item.new
    @cost = ShipCost.all
  end


  def create
    @item = Item.new(item_params)
    @item.size = "ここにサイズの名前が入ります"
    if @item.save
      redirect_to root_path
    else
      render new_sell_path unless @item.valid?
    end
  end

  def edit
    @item = Item.find(params[:id])
    @cost = ShipCost.all
    @images_length = @item.images.length
  end

  def update
    item = Item.find(params[:id])
    if item.user_id == current_user.id
      item.update(item_params)
      redirect_to root_path
    else
      render 'edit'
    end
  end

  

  private
  def item_params
    params.require(:item).permit(:user_id, :name, :description, :state_id, :ship_cost_id, :ship_delivery_id ,:ship_date_id, :price, :size, :category_id, :prefecture_id, images: [])
  end

  def need_login
    redirect_to login_index_path unless user_signed_in?
  end

  def set_header
    @header_parents = Category.where(ancestry: nil)
  end


  # def set_delivery
  #   @delivery_cost = ShipCost.find(@ship_cost_id)
  #   @delivery_way = ShipDelivery.find(@ship_delivery_id)
  #   @delivery_days = ShiDate.find(@ship_date_id)
  # end
end
