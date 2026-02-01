# config/routes.rb
Rails.application.routes.draw do
  # controllers オプションを追加
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  authenticated :user do
    root "tasks#index", as: :authenticated_root
    resources :tasks, only: [ :index, :create, :update, :edit ]
    resources :schedules, only: [ :edit, :update, :create ]
    resources :works, only: [ :index, :new, :create, :edit, :update, :destroy, :show ]
  end

  root to: redirect("/users/sign_in")

  # Activities用のルーティング
  resources :activities, only: [ :destroy ] do
    resources :comments, only: [ :create, :destroy ]
    resources :likes, only: [ :create, :destroy ]
  end

  # Chat_room用のルーティング
  resources :chat_rooms do
    resources :room_memberships, only: [ :create, :destroy ]
    # room_messagesに member ブロックを追加
    resources :room_messages, only: [ :create, :update, :destroy ] do
      member do
        get :thread
      end
    end
  end

  # SocialPost用のルーティング
  resources :social_posts, only: [ :index, :create, :update, :destroy ] do
    member do
      post :repost
      get :thread
    end
  end

  # Profile用のルーティング
  resources :profiles do
    member do
      patch :switch # /profiles/:id/switch
    end
  end

  # Team用のルーティング
  resource :team, only: [ :new, :create, :edit, :update ] do
    get :members
    resources :invitations, only: [ :create ], controller: "team_invitations" do
      collection do
        get :search
      end
      member do
        patch :cancel
        patch :accept
        patch :reject
      end
    end
  end

  # Schedule用のルーティング
  resources :schedule_invitations, only: [ :update ]
end
