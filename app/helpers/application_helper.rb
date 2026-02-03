# app/helpers/application_helper.rb
module ApplicationHelper
  def profile_avatar_tag(object, options = {}) # 引数名を profile から object に変えると分かりやすいです
    # デフォルトのサイズを設定
    size = options.delete(:size) || 100
    # ビューから渡された class とデフォルトの角丸スタイルを結合
    img_class = "rounded-xl object-cover #{options[:class]}"

    # object が avatar を持っていて、かつアタッチされているか確認
    if object.respond_to?(:avatar) && object.avatar.attached?
      image_tag object.avatar.variant(resize_to_fill: [ size, size ]),
                options.merge(class: img_class, style: "width: #{size}px; height: #{size}px; #{options[:style]}")
    else
      # name があればそれを使い、なければ display_name を使う。どちらもなければ "?"
      name_source = object.try(:name) || object.try(:display_name)
      initial = name_source.to_s[0]&.upcase || "?"

      content_tag :div, initial,
                  options.merge(
                    class: "#{img_class} bg-gray-400 flex items-center justify-center text-white font-bold",
                    style: "width: #{size}px; height: #{size}px; font-size: #{size / 2}px; #{options[:style]}"
                  )
    end
  end

  def team_avatar_tag(team, options = {})
    size = options.delete(:size) || 48 # デフォルト48px
    img_class = "rounded-xl object-cover #{options[:class]}"

    if team&.avatar&.attached?
      image_tag team.avatar.variant(resize_to_fill: [ size * 2, size * 2 ]),
                options.merge(class: img_class, style: "width: #{size}px; height: #{size}px; #{options[:style]}")
    else
      initial = team&.display_name&.first&.upcase || "T"
      content_tag :div, initial,
                  options.merge(
                    class: "#{img_class} bg-emerald-100 flex items-center justify-center text-emerald-600 font-bold",
                    style: "width: #{size}px; height: #{size}px; font-size: #{size / 2}px; #{options[:style]}"
                  )
    end
  end

  def status_color_class(status)
    case status.to_s
    when "todo", "0"
      "bg-amber-50 text-amber-600 border-amber-200"
    when "in_progress", "1"
      "bg-blue-50 text-blue-600 border-blue-200"
    when "done", "2"
      "bg-emerald-50 text-emerald-600 border-emerald-200"
    else
      "bg-gray-50 text-gray-600 border-gray-200"
    end
  end
end
