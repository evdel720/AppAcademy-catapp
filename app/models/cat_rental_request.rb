# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :integer          not null, primary key
#  cat_id     :integer          not null
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           default("PENDING"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CatRentalRequest < ActiveRecord::Base
  validates_inclusion_of :status, in: ['PENDING','DENIED', 'APPROVED']
  validates :cat_id, :start_date, :end_date, presence: true
  validate :period
  validate :does_not_overlap
  belongs_to :cat



  def period
    unless self.start_date < self.end_date
      self.errors[:start_date] << "is after end date!!"
    end
  end

  def overlapping_requests(rentals = CatRentalRequest.where.not(id: self.id).where(cat_id: self.cat_id))
    valid = rentals.reject do |rental|
      self.start_date > rental.end_date || self.end_date < rental.start_date
    end
  end

  def does_not_overlap
    # start_date is after all approved end_dates
    unless overlapping_approved_requests.empty?
      self.errors[:start_date] << "conflicts with approved rental!"
    end
  end

  def overlapping_approved_requests
    overlapping_requests(CatRentalRequest.where(status: "APPROVED", cat_id: self.cat_id))
  end

  def overlapping_pending_requests
    overlapping_requests(CatRentalRequest.where(status: "PENDING", cat_id: self.cat_id))
  end

  def approve!
    self.transaction do
      self.status = "APPROVED"
      self.save
      overlapping_pending_requests.each do |request|
        request.deny!
      end
    end
  end

  def deny!
    self.status = "DENIED"
    self.save
  end

  def pending?
    self.status == "PENDING"
  end

end
