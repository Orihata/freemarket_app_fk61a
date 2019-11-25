class SignupController < ApplicationController
before_action :return_to_root

  def index
    reset_session
  end

  def registration
    reset_session
    @user = User.new
  end

  def sms_confirmation
    birthday =  Date.new( user_params["birthday(1i)"].to_i,
                          user_params["birthday(2i)"].to_i,
                          user_params["birthday(3i)"].to_i)

    # validation
    # validation用に100%通る検査用インスタンスを作る
    @user = User.new(dummy_params)

    # 今回送ったフォームのアクションで生成した値で検査用インスタンスの該当箇所を上書きする
    @user.nickname = user_params[:nickname]
    @user.email = user_params[:email]
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]
    @user.last_name = user_params[:last_name]
    @user.first_name = user_params[:first_name]
    @user.last_name_kana = user_params[:last_name_kana]
    @user.first_name_kana = user_params[:first_name_kana]
    birthday = birthday
    # バリデーションに引っかかったら前のページにrenderする、検査用インスタンスにエラーメッセージが乗るので、前ページのviewで表示する

    # バリデーションがダメだったときに戻るページを指定する
    if params[:login_type] == "mail"
      render 'registration' and return unless @user.valid?
      render 'registration' and return unless verify_recaptcha
    elsif params[:login_type] == "sns"
      # passwordが消えてしまうので、改めてランダムな値を作ってあげる
      @password = Devise.friendly_token[0,20]
      render 'registration_sns' and return unless @user.valid?
      render 'registration_sns' and return unless verify_recaptcha
    end

    # 無事にバリデーションを通ったら、現在のuser_paramsの内容をsessionに一時保存する
    session[:nickname] = user_params[:nickname]
    session[:email] = user_params[:email]
    session[:password] = user_params[:password]
    session[:password_confirmation] = user_params[:password_confirmation]
    session[:last_name] = user_params[:last_name]
    session[:first_name] = user_params[:first_name]
    session[:last_name_kana] = user_params[:last_name_kana]
    session[:first_name_kana] = user_params[:first_name_kana]
    session[:birthday] = birthday
    @user = User.new
  end

  def sms
    # validation用に100%通る検査用インスタンスを作る
    @user = User.new(dummy_params)
    # 今回送ったフォームのアクションで生成した値で検査用インスタンスの該当箇所を上書きする
    @user.phone_number = user_params[:phone_number]
    # バリデーションに引っかかったら前のページにrenderする、検査用インスタンスにエラーメッセージが乗るので、前ページのviewで表示する
    render 'sms_confirmation' and return unless @user.valid?

    # バリデーションを通ったら、この値をsessionに保存する
    session[:phone_number] = user_params[:phone_number]


    # 取得した電話番号をもとに、認証番号を発行する機能を導入する
    # ６桁の数字をランダムで生成（する予定）、「SMS」ページでこれと一致するかでコントローラレベルのバリデーションをかける
    cert_num = random_gen(6)

    # twilio api(テスト用アカウントの為電話番号は登録している818039443443で固定、500円の無料枠から９円/回かかるのでテストは計画的に)

      # @client = Twilio::REST::Client.new Rails.application.credentials.twilio[:account_sid], Rails.application.credentials.twilio[:auth_token]
      # message = @client.messages.create(
      #     body: "認証番号：#{cert_num}",
      #     to: "+818039443443",
      #     from: "+12015540486")

    # 送れているかの確認
      # puts message.body

    # twilioはお金がかかるのでとりあえずテストするときはこちらで（ローカル上ではコンソール上に表示される）
    puts "認証番号：#{cert_num}"

    # Prod.環境では暗証番号入力画面のPlaceholderに（暫定的に）表示する
    session[:cert_num] = cert_num
    @cert_num = cert_num
  end

  def address
    @err_msg = "認証番号が違います"
    render "sms" and return unless session[:cert_num] == params[:confirm_number]
    @user = User.new
  end

  def payment
    # validation用に100%通る検査用インスタンスを作る
    @user = User.new(dummy_params)

    # 今回送ったフォームのアクションで生成した値で検査用インスタンスの該当箇所を上書きする
    @user.address_last_name = user_params[:address_last_name]
    @user.address_first_name = user_params[:address_first_name]
    @user.address_last_name_kana = user_params[:address_last_name_kana]
    @user.address_first_name_kana = user_params[:address_first_name_kana]
    @user.address_number = user_params[:address_number]
    @user.prefecture_id = user_params[:prefecture_id]
    @user.address_name = user_params[:address_name]
    @user.address_block = user_params[:address_block]
    @user.address_building = user_params[:address_building]
    @user.address_phone_number = user_params[:address_phone_number]

    # バリデーションに引っかかったら前のページにrenderする、検査用インスタンスにエラーメッセージが乗るので、前ページのviewで表示する
    render 'address' and return unless @user.valid?

    # sessionに保存
    session[:address_last_name] = user_params[:address_last_name]
    session[:address_first_name] = user_params[:address_first_name]
    session[:address_last_name_kana] = user_params[:address_last_name_kana]
    session[:address_first_name_kana] = user_params[:address_first_name_kana]
    session[:address_number] = user_params[:address_number]
    session[:prefecture_id] = user_params[:prefecture_id]
    session[:address_name] = user_params[:address_name]
    session[:address_block] = user_params[:address_block]
    session[:address_building] = user_params[:address_building]
    session[:address_phone_number] = user_params[:address_phone_number]
    @user = User.new
  end

  def create
    # 保存用のuserインスタンスを作る
    @user = User.new(
      nickname: session[:nickname],
      email: session[:email],
      password: session[:password],
      password_confirmation: session[:password_confirmation],
      last_name: session[:last_name], 
      first_name: session[:first_name], 
      last_name_kana: session[:last_name_kana], 
      first_name_kana: session[:first_name_kana], 
      birthday: session[:birthday],
      phone_number: session[:phone_number],
      address_last_name: session[:address_last_name],
      address_first_name: session[:address_first_name],
      address_last_name_kana: session[:address_last_name_kana],
      address_first_name_kana: session[:address_first_name_kana],
      address_number: session[:address_number],
      prefecture_id: session[:prefecture_id],
      address_name: session[:address_name],
      address_block: session[:address_block],
      address_building: session[:address_building],
      address_phone_number: session[:address_phone_number]
    )

    # 上記インスタンスを保存する
    if @user.save
      # 保存後にそのままログインするためにsessionについさっき作ったばかりのuserのidを保存する
      session[:id] = @user.id
      #SNS経由のアクセスであるならば（=sns_idが登録されているのであるならば）
      if session["devise.sns_id"]
        # セッションの最初に作ったsns_credentialのidからレコードを呼び出して
        sns = SnsCredential.find(session["devise.sns_id"])
        # そのレコードの「user_id」に、今誕生したUserのIDを紐づける。
        sns.update_attribute(:user_id, @user.id)
      end
        redirect_to finish_signup_index_path
    else
      redirect_to root_path
    end
  end

  def finish
    sign_in User.find(session[:id]) unless user_signed_in?
  end

  private
    def user_params
      params.require(:user).permit(
        :nickname, 
        :email, 
        :password, 
        :password_confirmation, 
        :last_name, 
        :first_name, 
        :last_name_kana, 
        :first_name_kana, 
        :"birthday(1i)",
        :"birthday(2i)",
        :"birthday(3i)",
        :phone_number,
        :address_last_name,
        :address_first_name,
        :address_last_name_kana,
        :address_first_name_kana,
        :address_number,
        :prefecture_id,
        :address_name,
        :address_block,
        :address_building,
        :address_phone_number
        )
    end

    def dummy_params
      # 「@user = User.new(dummy_params)」で、バリデーション用インスタンスを作る
      # 以下のダミーデータは、全てバリデーションを通過するものでなければならない。
      dummy = {nickname: "メルカリ太郎", 
        email: "aaa@xxx", 
        password: "dfdfdfdfasfadsfa", 
        password_confirmation: "dfdfdfdfasfadsfa", 
        last_name: "山田", 
        first_name: "太郎", 
        last_name_kana: "やまだ", 
        first_name_kana: "たろう", 
        phone_number: "0123456789",
        address_last_name: "山田",
        address_first_name: "太郎",
        address_last_name_kana: "やまだ",
        address_first_name_kana: "たろう",
        address_number: "1234567",
        prefecture_id: 1,
        address_name: "札幌市",
        address_block: "なんとか区なんとか",
        address_building: " ",
        address_phone_number: " "
       }
      return dummy
    end

    def random_gen(n)
      ''.tap { |s| n.times { s << rand(0..9).to_s } }
    end


    def return_to_root
      redirect_to root_path if user_signed_in?
    end
end
