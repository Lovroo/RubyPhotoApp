class Payment < ApplicationRecord
  attr_accessor :card_number, :card_cvv, :card_expires_month, :card_expires_year
  belongs_to :user

  def self.month_options
    Date::MONTHNAMES.compact.each_with_index.map { |name, i| ["#{i+1} - #{name}", i+1] }
  end

  def self.year_options
    (Date.today.year..(Date.today.year+10)).to_a
  end

  def process_payment
    @Payment = Payment.last
    customer = Stripe::Customer.create email: email, card:token
    card = Stripe::PaymentMethod.create({
                                   type: 'card',
                                   card: {
                                     number: @Payment.card_number,
                                     exp_month: @Payment.card_expires_month,
                                     exp_year: @Payment.card_expires_year,
                                     cvc: @Payment.card_cvv
                                   },                                 })
    usedCard = Stripe::PaymentMethod.attach(card.id, customer: customer.id)
    Stripe::PaymentIntent.create customer: customer.id, amount: 1000, description: 'Premium subscription', currency: 'eur',
                                 setup_future_usage: 'on_session',
                                 payment_method_types: ['card'], payment_method: usedCard.id
  end
end
