class CategoriesController < ApplicationController
before_action :set_header

  def index
    @parents = Category.where(ancestry: nil)
  end

  def show
    @category = Category.find(params[:id])
    # 今の時点では、「レディース」ならば「レディース」のみが表示されるが、将来的には、子カテゴリ以下すべてのものを表示したい
    @items = Item.where(category_id: [params[:id]] + @category.subtree.to_a)
  end

  def set_header
    @header_parents = Category.where(ancestry: nil)
  end
end
