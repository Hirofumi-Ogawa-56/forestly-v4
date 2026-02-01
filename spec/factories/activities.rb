# spec/factories/activities.rb
FactoryBot.define do
  factory :activity do
    association :owner_profile, factory: :profile
    title { "テストアクティビティ" }
    visibility_range { :is_private }
    permission_type { :read_only } # 追加
    status { :active }

    # Work用
    trait :with_work do
      association :actable, factory: :work
    end

    # Task用
    trait :with_task do
        association :actable, factory: :task
    end

    # Schedule用
    trait :with_schedule do
        association :actable, factory: :schedule
    end
  end
end

# Work用
FactoryBot.define do
  factory :work do
    association :actable, factory: :note
  end
end

# Note用
FactoryBot.define do
  factory :note do
    # Noteはhas_rich_text :content なので、このように指定します
    content { "<div>テスト本文です</div>" }
  end
end

# Task用
FactoryBot.define do
  factory :task do
    task_status { :todo }
  end
end

# Schedule用
FactoryBot.define do
  factory :schedule do
    schedule_status { :confirmed }
  end
end
