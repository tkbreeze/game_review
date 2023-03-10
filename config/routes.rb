Rails.application.routes.draw do
  get 'users/show'
  devise_for :users, controllers: {
    # ↓ローカルに追加されたコントローラーを参照する(コントローラー名: "コントローラーの参照先")
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }
  root to: 'games#index'
  resources :games, only: [:index, :show] do
    resources :reviews
  end
end
