module ApplicationHelper
  # Renders a mount point for a React component (see app/javascript/react/mount.jsx)
  def react_component(name, props = {}, tag: :div, **options)
    content_tag(tag, "", **options.merge(
      data: { react_component: name, props: props.to_json }
    ))
  end

  def money(cents, currency = "$")
    "#{currency}#{number_with_delimiter(format('%.2f', cents.to_i / 100.0))}"
  end

  ORDER_STATUS_TONES = {
    "pending" => "orange", "processing" => "blue", "shipped" => "purple",
    "delivered" => "green", "cancelled" => "red"
  }.freeze

  PAYMENT_STATUS_TONES = {
    "pending" => "orange", "succeeded" => "green", "failed" => "red", "refunded" => "gray"
  }.freeze

  INVOICE_STATUS_TONES = {
    "draft" => "gray", "issued" => "blue", "paid" => "green", "void" => "red"
  }.freeze

  def status_badge(status, tones)
    tone = tones[status.to_s] || "gray"
    content_tag(:span, status.to_s.humanize, class: "badge badge-#{tone}")
  end

  def order_status_badge(order)   = status_badge(order.status, ORDER_STATUS_TONES)
  def payment_status_badge(pay)   = status_badge(pay.status, PAYMENT_STATUS_TONES)
  def invoice_status_badge(inv)   = status_badge(inv.status, INVOICE_STATUS_TONES)

  def seller_status_badge(seller)
    if seller.pending?
      content_tag(:span, "Pending approval", class: "badge badge-orange")
    elsif !seller.enabled?
      content_tag(:span, "Disabled", class: "badge badge-red")
    else
      content_tag(:span, "Active", class: "badge badge-green")
    end
  end

  def avatar_tag(name, url, size: 30)
    if url.present?
      image_tag(url, alt: name, class: "avatar", style: "width:#{size}px;height:#{size}px", referrerpolicy: "no-referrer")
    else
      initials = name.to_s.split(/\s+/).first(2).filter_map { |w| w[0] }.join.upcase
      content_tag(:span, initials, class: "avatar-fallback", style: "width:#{size}px;height:#{size}px")
    end
  end

  def side_link(label, path, icon, active:)
    link_to(path, class: "side-link #{'active' if active}") do
      safe_join([ sidebar_icon(icon), label ])
    end
  end

  ICONS = {
    dashboard: '<rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/>',
    customers: '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6"/><circle cx="17" cy="9" r="2.5"/><path d="M16.5 14.5c2.8 0 5 2 5 5"/>',
    orders: '<path d="M4 7l8-4 8 4v10l-8 4-8-4z"/><path d="M4 7l8 4 8-4"/><path d="M12 11v10"/>',
    sellers: '<path d="M3 9l1.5-5h15L21 9"/><path d="M3 9a3 3 0 006 0 3 3 0 006 0 3 3 0 006 0"/><path d="M5 11v9h14v-9"/><path d="M9 20v-5h6v5"/>',
    addresses: '<path d="M12 21s-7-5.5-7-11a7 7 0 0114 0c0 5.5-7 11-7 11z"/><circle cx="12" cy="10" r="2.5"/>',
    shop: '<path d="M3 9l1.5-5h15L21 9"/><path d="M5 11v9h14v-9"/>'
  }.freeze

  def sidebar_icon(name)
    raw_path = ICONS[name] || ICONS[:dashboard]
    content_tag(:svg, raw_path.html_safe,
                width: 17, height: 17, viewBox: "0 0 24 24", fill: "none",
                stroke: "currentColor", "stroke-width": "1.8",
                "stroke-linecap": "round", "stroke-linejoin": "round", "aria-hidden": "true")
  end
end
