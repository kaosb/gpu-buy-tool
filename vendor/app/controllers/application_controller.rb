class ApplicationController < ActionController::API
  
  def health
    render json: { status: true, message: 'GPU buy tool API V1 by @kaosb.' }, status: :ok
  end
  
  def search
    if params[:q].present?
      status = true
      result = ebay_search( search = params[:q], criteria = 0 )
      result[:products].each do |product|
        if Product.exists?( item_id: product[:item_id] )
          Product.where( item_id: product[:item_id] ).update_all(
            price: product[:price],
            bids: product[:bids],
            time_left: product[:time_left],
          )
        else
          Product.create!(
            title: product[:title],
            url: product[:url],
            img: product[:img],
            price: product[:price],
            bids: product[:bids],
            time_left: product[:time_left],
            shipping: product[:shipping],
            item_id: product[:item_id]
          )
        end
      end
    else
      status = false
      result = []
    end
    render json: { status: status, result: result }, status: :ok
  end
  
  def ebay_search( search, criteria = nil )
    require 'watir'
    args = []
    args << '--disable-translate'
    args << '--lang=en-US'
    browser = Watir::Browser.new :chrome, options: { args: args }, headless: true
    # browser = Watir::Browser.new :firefox, headless: true
    browser.goto 'www.ebay.com'
    browser.element(id: 'gh-ac').set search
    browser.element(id: 'gh-btn').click
    if criteria
      browser.button(visible_text: 'Mejor resultado').click
      browser.span(visible_text: 'Duración: primeros en finalizar').click
    end
    title = browser.title
    products = []
    result = browser.divs(class: ['s-item__wrapper', 'clearfix'])
    result.each do |item|
      obj = {}
      obj[:title] = item.h3.text
      obj[:url] = item.a.href
      obj[:item_id] = item.a.href.split('/').last.split('?').first
      if item.div(class: 's-item__image-section').div(class: 's-item__image').div(class: 's-item__image-wrapper').img.exists?
        obj[:img] = item.div(class: 's-item__image-section').div(class: 's-item__image').div(class: 's-item__image-wrapper').img.src
      end
      item.divs(class: ['s-item__detail', 's-item__detail--primary']).each do |row|
        row.element(class: 's-item__price').exists? ? obj[:price] = row.element(class: 's-item__price').text : nil
        row.element(class: 's-item__bidCount').exists? ? obj[:bids] = row.element(class: 's-item__bidCount').text : nil
        row.element(class: 's-item__time').exists? ? obj[:time_left] = row.element(class: 's-item__time').text : nil
        row.element(class: 's-item__shipping').exists? ? obj[:shipping] = row.element(class: 's-item__shipping').text : nil
        row.element(class: 'SECONDARY_INFO').exists? ? obj[:secondary_info] = row.element(class: 'SECONDARY_INFO').text : nil
      end
      products.push(obj)
    end
    products.shift
    quantity = products.count
    browser.close
    { title: title, search: search, quantity: quantity, products: products }
  end

end
