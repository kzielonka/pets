class FakeTime
  def initialize
    @now = Time.new(2000, 1, 1, 0, 0, 0, 0)
  end

  def call
    @now
  end

  def change(time)
    @now = time.to_time
  end
end
