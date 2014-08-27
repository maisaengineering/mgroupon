RailsAdmin.config do |config|

  #Fix for kaminari and will_paginate conflict fix. Proposed solution not working for mongoid so,
  Kaminari::Hooks.init

  config.included_models = [ "Admin" ,"User"]

  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)



  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      only [ Admin ]
    end
    export
    bulk_delete do
      only [Admin]
    end
    show do
      only [Admin]
    end
    edit do
      only [Admin]
    end
    delete do
      only [Admin]
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end



  # Admin ------------------------------------------
  config.model 'Admin' do
    label "Admin User"

    list do
      field :fname
      field :lname
      field :email
      field :sign_in_count
    end

    edit do
      field :fname
      field :lname
      field :email
      field :password
      field :password_confirmation
    end

  end

  # User --------------------------------------------
  config.model 'User' do
    list do
      field :first_name
      field :last_name
      field :email
      field :sign_in_count
      field :created_at
      field :updated_at
    end
  end





end
