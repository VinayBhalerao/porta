module VerticalNavHelper
  def vertical_nav_sections
    case active_menu
    when :personal, :account
      account_nav_sections
    when :buyers, :finance, :cms, :site, :settings, :audience
      audience_nav_sections
    # - when :apis, :applications, :active_docs

    #   - if can? :manage, :partners
    #     = render vertical_nav_item,
    #             title: 'ActiveDocs',
    #             path: admin_api_docs_services_path,
    #             icon: 'file-text'

    #   - if can?(:manage, :monitoring)
    #     - if current_user.multiple_accessible_services?
    #       = render vertical_nav_item,
    #               title: 'Alerts',
    #               path: admin_alerts_path,
    #               icon:  'exclamation-triangle'

    # - when :serviceadmin, :monitoring
    #   = render 'shared/provider/navigation/service/nav',
    #           vertical_nav_item: vertical_nav_item,
    #           layout_secondary_nav: layout_secondary_nav
    end.to_json
  end

  # Account
  def account_nav_sections
    sections = []

    if can? :manage, current_account
      sections << {id: :overview, title: 'Overview', path: provider_admin_account_path}
    end

    if can? :manage, current_user
      sections << {id: :personal, title: 'Personal', items: account_personal_items}
    end

    if can? :manage, current_account
      unless current_account.provider_can_use? :new_notification_system
        sections << {id: :notifications, title: 'Notifications', path: provider_admin_account_notifications_path}
      end

      sections << {id: :users, title: 'Users', items: account_users_items}

      if ThreeScale.master_billing_enabled? && !current_account.master?
        sections << {id: :billing, title: 'Billing', items: account_billing_items}
      end
    end

    sections << {id: :integrate, title: 'Integrate', items: account_itegrate_items}

    if can? :export, :data
      sections << {id: :export, title: 'Export', path: new_provider_admin_account_data_exports_path}
    end

    sections
  end

  def account_personal_items
    items = []

    if can? :manage, current_user
      items << {id: :personal_details, title: 'Personal Details', path: edit_provider_admin_user_personal_details_path}
    end

    items << {id: :tokens, title: 'Tokens', path: provider_admin_user_access_tokens_path}

    if can? :show, current_user.notification_preferences
      items << {id: :notification_preferences, title: 'Notification Preferences', path: provider_admin_user_notification_preferences_path}
    end

    items
  end

  def account_users_items
    items = []

    if can? :manage, User
      items << {id: :listing, title: 'Listing', path: provider_admin_account_users_path}

      if can? :manage, :multiple_users && !current_account.settings.enforce_sso?
        items << {id: :invitations, title: 'Invitations', path: provider_admin_account_invitations_path}
      end
    end

    if current_account.provider_can_use? :provider_sso
      items << {id: :sso_integrations, title: 'SSO Integrations', path: provider_admin_account_authentication_providers_path}
    end

    items
  end

  def account_billing_items
    items = []

    if can?(:read, Invoice) && !ThreeScale.config.onpremises
      items << {id: :invoices, title: '3scale Invoices', path: provider_admin_account_invoices_path}
    end

    if can?(:manage, :credit_card) && !ThreeScale.config.onpremises
      items << {id: :payment_details, title: 'Payment Details', path: provider_admin_account_braintree_blue_path}
    end

    items
  end

  def account_itegrate_items
    items = []

    if can? :manage, :web_hooks
      items << {id: :webhooks, title: 'Webhooks', path: edit_provider_admin_webhooks_path}
    end

    items << {id: :apidocs, title: '3scale API Docs', path: provider_admin_api_docs_path}

    items
  end

  # Audience
  def audience_nav_sections
    sections = []

    if can?(:manage, :partners) || can?(:manage, :settings)
      sections << {id: :accounts, title: 'Accounts', items: audience_accounts_items}
    end
  
    if can? :manage, :applications
      sections << {id: :applications, title: 'Applications', items: audience_applications_items}
    end
    
    if can?(:see, :finance) && (can?(:manage, :finance) || can?(:manage, :settings))
      sections << {id: :finance, title: 'Billing', items: audience_billing_items}
    end
    
    if (can?(:manage, :portal) || can?(:manage, :settings) || can?(:manage, :plans)) && !master_on_premises?
      sections << {id: :cms, title: 'Developer Portal', items: audience_portal_items}
    end
    
    sections << {id: :messages, title: 'Messages', items: audience_messages_items}
    
    if can?(:manage, :portal) && current_account.forum_enabled?
      sections << {id: :forum, title: 'Forum', items: audience_forum_items}
    end

    sections
  end

  def audience_accounts_items
    items = []

    if can? :manage, :partners
      items << {id: :listing, title: 'Listing', path: admin_buyers_accounts_path}
    end
  
    if can?(:manage, :plans) && current_account.settings.account_plans.allowed? && current_account.settings.account_plans_ui_visible?
      items << {id: :acount_plans, title: 'Account Plans', path: admin_buyers_account_plans_path}
    end
    
    if can?(:manage, :service_contracts) && current_account.settings.service_plans.allowed? && current_account.settings.service_plans_ui_visible?
      items << {id: :subscriptions, title: 'Subscriptions', path: admin_buyers_service_contracts_path}
    end
    
    if can?(:manage, :settings)
      items << {title: 'Settings'}
      items << {id: :usage_rules, title: 'Usage Rules', path: edit_admin_site_usage_rules_path}
      items << {id: :fields_definition, title: 'Fields Definitions', path: admin_fields_definitions_path}
    end

    items
  end

  def audience_applications_items
    items = []

    if can? :manage, :partners
      items << {id: :listing, title: 'Listing', path: admin_buyers_applications_path}
    end
  
    if can?(:manage, :monitoring)
      items << {id: :alerts, title: 'Alerts', path: admin_alerts_path}
    end

    items
  end

  def audience_billing_items
    items = []

    if can?(:manage, :finance)
      items << {id: :earnings, title: 'Earnings by Month', path: admin_finance_root_path}
      items << {id: :invoices, title: 'Invoices', path: admin_finance_invoices_path}
  
      if current_user.username == ThreeScale.config.impersonation_admin['username']
        items << {id: :finance, title: 'Finance Log', path: admin_finance_log_entries_path}
      end
    end
  
    if can?(:manage, :settings)
      items << {title: 'Settings'}

      # this setting needs more than just editing auth, as such it's not a setting
      if can?(:manage, :finance)
        items << {id: :charging, title: 'Charging & Gateway', path: admin_finance_settings_path}
      end
    
      items << {id: :credit_card_policies, title: 'Credit Card Policies', path: edit_admin_site_settings_path}
    end

    items
  end

  def audience_portal_items
    items = []

    if can?(:manage, :portal)
      items << {id: :content, title: 'Content', path: provider_admin_cms_templates_path}
      items << {id: :drafts, title: 'Drafts', path: provider_admin_cms_changes_path}
      items << {id: :redirects, title: 'Redirects', path: provider_admin_cms_redirects_path}
    
      if can?(:see, :groups)
        items << {id: :groups, title: 'Groups', path: provider_admin_cms_groups_path}
      end
    
      if can? :update, :logo
        items << {id: :logo, title: 'Logo', path: edit_provider_admin_account_logo_path}
      end
    
      items << {id: :feature_visibility, title: 'Feature Visibility', path: provider_admin_cms_switches_path}
    
      if can? :manage, :plans
        items << {id: :activedocs, title: 'ActiveDocs', path: admin_api_docs_services_path}
      end
    end

    items << {title: ' '} # Blank space
    items << {title: 'Visit Portal', path: access_code_url(host: current_account.domain, cms_token: current_account.settings.cms_token!)}
    
    if can?(:manage, :portal)
      items << {title: 'Legal Terms'}
      items << {id: :signup, title: 'Signup', path: edit_legal_terms_url(CMS::Builtin::LegalTerm::SIGNUP_SYSTEM_NAME)}
      items << {id: :service_subscriptions, title: 'Service Subscription', path: edit_legal_terms_url(CMS::Builtin::LegalTerm::SUBSCRIPTION_SYSTEM_NAME)}
      items << {id: :new_application, title: 'New Application', path: edit_legal_terms_url(CMS::Builtin::LegalTerm::NEW_APPLICATION_SYSTEM_NAME)}
    end
    
    if can?(:manage, :settings)
      items << {title: 'Settings'}
      items << {id: :domain, title: 'Domains & Access', path: admin_site_dns_path}
      items << {id: :spam_protection, title: 'Spam Protection', path: edit_admin_site_spam_protection_path}
    
      if current_account.show_xss_protection_options?
        items << {id: :xss_protection, title: 'XSS Protection', path: edit_admin_site_developer_portal_path}
        items << {id: sso_integrations, title: 'SSO Integrations', path: provider_admin_authentication_providers_path}
      end
    
      if !current_account.forum_enabled? && provider_can_use?(:forum)
        items << {id: :forum_settings, title: 'Forum Settings', path: edit_admin_site_forum_path}
      end
    end
    
    items << {title: 'Docs'}
    items << {id: :liquid_reference, title: 'Liquid Reference', path: provider_admin_liquid_docs_path}

    items
  end

  def audience_messages_items
    items = []
    items << {id: :inbox, title: 'Inbox', path: provider_admin_messages_root_path}
    items << {id: :sent_messages, title: 'Sent messages', path: provider_admin_messages_outbox_index_path}
    items << {id: :trash, title: 'Trash', path: provider_admin_messages_trash_index_path}
    
    if can?(:manage, :settings) && !master_on_premises?
      items << {title: 'Settings'}
      items << {id: :support_emails, title: 'Support Emails', path: edit_admin_site_emails_path}
      items << {id: :email_templates, title: 'Email Templates', path: provider_admin_cms_email_templates_path}
    end

    items
  end

  def audience_forum_items
    items = []
    items << {id: :threads, title: 'Threads', path: admin_forum_path}
    items << {id: :categories, title: 'Categories', path: forum_categories_path}
    
    if logged_in?
      items << {id: :my_threads, title: 'My Threads', path: my_admin_forum_topics_path}
    end
    
    if user_has_subscriptions?
      items << {id: :my_subscriptions, title: 'My subscriptions', path: forum_subscriptions_path}
    end
    
    if can?(:manage, :settings)
      items << {title: ' '} # Blank space
      items << {id: :preferences, title: 'Preferences', path: edit_admin_site_forum_path}
    end

    items
  end
end