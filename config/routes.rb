Rails.application.routes.draw do
  root "home#index"

  # ── Sellers: email/password auth ──────────────────────────────────────────
  devise_for :sellers, controllers: { registrations: "sellers/registrations" }

  namespace :sellers, path: "seller" do
    get "pending_approval", to: "onboarding#pending_approval"
    get "dashboard", to: "dashboard#show"
    resources :customers, only: [ :index, :show ]
    resources :orders, only: [ :index, :show ]
  end

  # ── Customers: Facebook Connect only ──────────────────────────────────────
  devise_for :customers,
             controllers: { omniauth_callbacks: "customers/omniauth_callbacks" },
             skip: [ :sessions ]
  devise_scope :customer do
    delete "customers/sign_out", to: "customers/sessions#destroy", as: :destroy_customer_session
  end

  # Public storefront per seller — entry point for customer Facebook login
  get "s/:slug", to: "storefronts#show", as: :storefront

  # Legal pages (required by Facebook for Live apps)
  get "privacy", to: "pages#privacy", as: :privacy
  get "data-deletion", to: "pages#data_deletion", as: :data_deletion

  namespace :portal do
    get "dashboard", to: "dashboard#show"
    resources :orders, only: [ :index, :show ]
    resources :addresses do
      patch :make_default, on: :member
    end
  end

  # ── Administrators ─────────────────────────────────────────────────────────
  devise_for :admins

  namespace :admin do
    get "dashboard", to: "dashboard#show"
    resources :sellers, only: [ :index, :show ] do
      member do
        patch :approve
        patch :toggle_enabled
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
