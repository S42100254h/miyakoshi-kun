class LinebotController < ApplicationController
  require 'line/bot'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
        # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          input = event.message['text']

          case input
          when 1
            push = "おおぉおーー！\nそれはカップラーメン（デブの元）じゃいなか！！\nうっひょひょひょひょーー！！"
            displayCommand()
          when 2
            push = "いや、最近7kg太った、、。"
            displayCommand()
          when 3
            push = "あん？？？ワロス"
            displayCommand()
          when 4
            push = "ごめん。足折って入院してる。"
            displayCommand()
          end
        end
        
      # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)

      # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    def displayCommand
      push = "1. ほら、エサだぞ。\n2. あれ？最近痩せた？\n3. ん？ちょっと太った、、？\n4. バドミントンしようぜ！"
    end
end
